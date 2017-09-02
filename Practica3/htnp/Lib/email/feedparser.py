# Copyright (C) 2004-2006 Python Software Foundation
# Authors: Baxter, Wouters and Warsaw
# Contact: email-sig@python.org

"""FeedParser - An email feed parser.

The feed parser implements an interface for incrementally parsing an email
message, line by line.  This has advantages for certain applications, such as
those reading email messages off a socket.

FeedParser.feed() is the primary interface for pushing new data into the
parser.  It returns when there's nothing more it can do with the available
data.  When you have no more data to push into the parser, call .close().
This completes the parsing and returns the root message object.

The other advantage of this parser is that it will never throw a parsing
exception.  Instead, when it finds something unexpected, it adds a 'defect' to
the current message.  Defects are just instances that live on the message
object's .defects attribute.
"""

__all__ = ['FeedParser']

import re

from email import errors
from email import message

NLCRE = re.compile('\r\n|\r|\n')
NLCRE_bol = re.compile('(\r\n|\r|\n)')
NLCRE_eol = re.compile('(\r\n|\r|\n)$')
NLCRE_crack = re.compile('(\r\n|\r|\n)')
# RFC 2822 $3.6.8 Optional fields.  ftext is %d33-57 / %d59-126, Any character
# except controls, SP, and ":".
headerRE = re.compile(r'^(From |[\041-\071\073-\176]{1,}:|[\t ])')
EMPTYSTRING = ''
NL = '\n'

NeedMoreData = object()



class BufferedSubFile(object):
    """A file-ish object that can have new data loaded into it.

    You can also push and pop line-matching predicates onto a stack.  When the
    current predicate matches the current line, a false EOF response
    (i.e. empty string) is returned instead.  This lets the parser adhere to a
    simple abstraction -- it parses until EOF closes the current message.
    """
    def __init__(self):
        # The last partial line pushed into this object.
        self._partial = ''
        # The list of full, pushed lines, in reverse order
        self._lines = []
        # The stack of false-EOF checking predicates.
        self._eofstack = []
        # A flag indicating whether the file has been closed or not.
        self._closed = False

    def push_eof_matcher(self, pred):
        self._eofstack.append(pred)

    def pop_eof_matcher(self):
        return self._eofstack.pop()

    def close(self):
        # Don't forget any trailing partial line.
        self._lines.append(self._partial)
        self._partial = ''
        self._closed = True

    def readline(self):
        if not self._lines:
            if self._closed:
                return ''
            return NeedMoreData
        # Pop the line off the stack and see if it matches the current
        # false-EOF predicate.
        line = self._lines.pop()
        # RFC 2046, section 5.1.2 requires us to recognize outer level
        # boundaries at any level of inner nesting.  Do this, but be sure it's
        # in the order of most to least nested.
        for ateof in self._eofstack[::-1]:
            if ateof(line):
                # We're at the false EOF.  But push the last line back first.
                self._lines.append(line)
                return ''
        return line

    def unreadline(self, line):
        # Let the consumer push a line back into the buffer.
        assert line is not NeedMoreData
        self._lines.append(line)

    def push(self, data):
        """Push some new data into this object."""
        # Handle any previous leftovers
        data, self._partial = self._partial + data, ''
        # Crack into lines, but preserve the newlines on the end of each
        parts = NLCRE_crack.split(data)
        # The *ahem* interesting behaviour of re.split when supplied grouping
        # parentheses is that the last element of the resulting list is the
        # data after the final RE.  In the case of a NL/CR terminated string,
        # this is the empty string.
        self._partial = parts.pop()
        # parts is a list of strings, alternating between the line contents
        # and the eol character(s).  Gather up a list of lines after
        # re-attaching the newlines.
        lines = []
        for i in range(len(parts) // 2):
            lines.append(parts[i*2] + parts[i*2+1])
        self.pushlines(lines)

    def pushlines(self, lines):
        # Reverse and insert at the front of the lines.
        self._lines[:0] = lines[::-1]

    def is_closed(self):
        return self._closed

    def __iter__(self):
        return self

    def next(self):
        line = self.readline()
        if line == '':
            raise StopIteration
        return line



class FeedParser:
    """A feed-style parser of email."""

    def __init__(self, _factory=message.Message):
        """_factory is called with no arguments to create a new message obj"""
        self._factory = _factory
        self._input = BufferedSubFile()
        self._msgstack = []
        self._parse = self._parsegen().next
        self._cur = None
        self._last = None
        self._headersonly = False

    # Non-public interface for supporting Parser's headersonly flag
    def _set_headersonly(self):
        self._headersonly = True

    def feed(self, data):
        """Push more data into the parser."""
        self._input.push(data)
        self._call_parse()

    def _call_parse(self):
        try:
            self._parse()
        except StopIteration:
            pass

    def close(self):
        """Parse all remaining data and return the root message object."""
        self._input.close()
        self._call_parse()
        root = self._pop_message()
        assert not self._msgstack
        # Look for final set of defects
        if root.get_content_maintype() == 'multipart' \
               and not root.is_multipart():
            root.defects.append(errors.MultipartInvariantViolationDefect())
        return root

    def _new_message(self):
        msg = self._factory()
        if self._cur and self._cur.get_content_type() == 'multipart/digest':
            msg.set_default_type('message/rfc822')
        if self._msgstack:
            self._msgstack[-1].attach(msg)
        self._msgstack.append(msg)
        self._cur = msg
        self._last = msg

    def _pop_message(self):
        retval = self._msgstack.pop()
        if self._msgstack:
            self._cur = self._msgstack[-1]
        else:
            self._cur = None
        return retval

    def _parsegen(self):
        # Create a new message and start by parsing headers.
        self._new_message()
        headers = []
        # Collect the headers, searching for a line that doesn't match the RFC
        # 2822 header or continuation pattern (including an empty line).
        for line in self._input:
            if line is NeedMoreData:
                yield NeedMoreData
                continue
            if not headerRE.match(line):
                # If we saw the RFC defined header/body separator
                # (i.e. newline), just throw it away. Otherwise the line is
                # part of the body so push it back.
                if not NLCRE.match(line):
                    self._input.unreadline(line)
                break
            headers.append(line)
        # Done with the headers, so parse them and figure out what we're
        # supposed to see in the body of the message.
        self._parse_headers(headers)
        # Headers-only parsing is a backwards compatibility hack, which was
        # necessary in the older parser, which could throw errors.  All
        # remaining lines in the input are thrown into the message body.
        if self._headersonly:
            lines = []
            while True:
                line = self._input.readline()
                if line is NeedMoreData:
                    yield NeedMoreData
                    continue
                if line == '':
                    break
                lines.append(line)
            self._cur.set_payload(EMPTYSTRING.join(lines))
            return
        if self._cur.get_content_type() == 'message/delivery-status':
            # message/delivery-status contains blocks of headers separated by
            # a blank line.  We'll represent each header block as a separate
            # nested message object, but the processing is a bit different
            # than standard message/* types because there is no body for the
            # nested messages.  A blank line separates the subparts.
            while True:
                self._input.push_eof_matcher(NLCRE.match)
                for retval in self._parsegen():
                    if retval is NeedMoreData:
                        yield NeedMoreData
                        continue
                    break
                msg = self._pop_message()
                # We need to pop the EOF matcher in order to tell if we're at
                # the end of the current file, not the end of the last block
                # of message headers.
                self._input.pop_eof_matcher()
                # The input stream must be sitting at the newline or at the
                # EOF.  We want to see if we're at the end of this subpart, so
                # first consume the blank line, then test the next line to see
                # if we're at this subpart's EOF.
                while True:
                    line = self._input.readline()
                    if line is NeedMoreData:
                        yield NeedMoreData
                        continue
                    break
                while True:
                    line = self._input.readline()
                    if line is NeedMoreData:
                        yield NeedMoreData
                        continue
                    break
                if line == '':
                    break
                # Not at EOF so this is a line we're going to need.
                self._input.unreadline(line)
            return
        if self._cur.get_content_maintype() == 'message':
            # The message claims to be a message/* type, then what follows is
            # another RFC 2822 message.
            for retval in self._parsegen():
                if retval is NeedMoreData:
                    yield NeedMoreData
                    continue
                break
            self._pop_message()
            return
        if self._cur.get_content_maintype() == 'multipart':
            boundary = self._cur.get_boundary()
            if boundary is None:
                # The message /claims/ to be a multipart but it has not
                # defined a boundary.  That's a problem which we'll handle by
                # reading everything until the EOF and marking the message as
                # defective.
                self._cur.defects.append(errors.NoBoundaryInMultipartDefect())
                lines = []
                for line in self._input:
                    if line is NeedMoreData:
                        yield NeedMoreData
                        continue
                    lines.append(line)
                self._cur.set_payload(EMPTYSTRING.join(lines))
                return
            # Create a line match predicate which matches the inter-part
            # boundary as well as the end-of-multipart boundary.  Don't push
            # this onto the input stream until we've scanned past the
            # preamble.
            separator = '--' + boundary
            boundaryre = re.compile(
                '(?P<sep>' + re.escape(separator) +
                r')(?P<end>--)?(?P<ws>[ \t]*)(?P<linesep>\r\n|\r|\n)?$')
            capturing_preamble = True
            preamble = []
            linesep = False
            while True:
                line = self._input.readline()
                if line is NeedMoreData:
                    yield NeedMoreData
                    continue
                if line == '':
                    break
                mo = boundaryre.match(line)
                if mo:
                    # If we're looking at the end boundary, we're done with
                    # this multipart.  If there was a newline at the end of
                    # the closing boundary, then we need to initialize the
                    # epilogue with the empty string (see below).
                    if mo.group('end'):
                        linesep = mo.group('linesep')
                        break
                    # We saw an inter-part boundary.  Were we in the preamble?
                    if capturing_preamble:
                        if preamble:
                            # According to RFC 2046, the last newline belongs
                            # to the boundary.
                            lastline = preamble[-1]
                            eolmo = NLCRE_eol.search(lastline)
                            if eolmo:
                                preamble[-1] = lastline[:-len(eolmo.group(0))]
                            self._cur.preamble = EMPTYSTRING.join(preamble)
                        capturing_preamble = False
                        self._input.unreadline(line)
                        continue
                    # We saw a boundary separating two parts.  Consume any
                    # multiple boundary lines that may be following.  Our
                    # interpretation of RFC 2046 BNF grammar does not produce
                    # body parts within such double boundaries.
                    while True:
                        line = self._input.readline()
                        if line is NeedMoreData:
                            yield NeedMoreData
                            continue
                        mo = boundaryre.match(line)
                        if not mo:
                            self._input.unreadline(line)
                            break
                    # Recurse to parse this subpart; the input stream points
                    # at the subpart's first line.
                    self._input.push_eof_matcher(boundaryre.match)
                    for retval in self._parsegen():
                        if retval is NeedMoreData:
                            yield NeedMoreData
                            continue
                        break
                    # Because of RFC 2046, the newline preceding the boundary
                    # separator actually belongs to the boundary, not the
                    # previous subpart's payload (or epilogue if the previous
                    # part is a multipart).
                    if self._last.get_content_maintype() == 'multipart':
                        epilogue = self._last.epilogue
                        if epilogue == '':
                            self._last.epilogue = None
                        elif epilogue is not None:
                            mo = NLCRE_eol.search(epilogue)
                            if mo:
                                end = len(mo.group(0))
                                self._last.epilogue = epilogue[:-end]
                    else:
                        payload = self._last.get_payload()
                        if isinstance(payload, basestring):
                            mo = NLCRE_eol.search(payload)
                            if mo:
                                payload = payload[:-len(mo.group(0))]
                                self._last.set_payload(payload)
                    self._input.pop_eof_matcher()
                    self._pop_message()
                    # Set the multipart up for newline cleansing, which will
                    # happen if we're in a nested multipart.
                    self._last = self._cur
                else:
                    # I think we must be in the preamble
                    assert capturing_preamble
                    preamble.append(line)
            # We've seen either the EOF or the end boundary.  If we're still
            # capturing the preamble, we never saw the start boundary.  Note
            # that as a defect and store the captured text as the payload.
            # Everything from here to the EOF is epilogue.
            if capturing_preamble:
                self._cur.defects.append(errors.StartBoundaryNotFoundDefect())
                self._cur.set_payload(EMPTYSTRING.join(preamble))
                epilogue = []
                for line in self._input:
                    if line is NeedMoreData:
                        yield NeedMoreData
                        continue
                self._cur.epilogue = EMPTYSTRING.join(epilogue)
                return
            # If the end boundary ended in a newline, we'll need to make sure
            # the epilogue isn't None
            if linesep:
                epilogue = ['']
            else:
                epilogue = []
            for line in self._input:
                if line is NeedMoreData:
                    yield NeedMoreData
                    continue
                epilogue.append(line)
            # Any CRLF at the front of the epilogue is not technically part of
            # the epilogue.  Also, watch out for an empty string epilogue,
            # which means a single newline.
            if epilogue:
                firstline = epilogue[0]
                bolmo = NLCRE_bol.match(firstline)
                if bolmo:
                    epilogue[0] = firstline[len(bolmo.group(0)):]
            self._cur.epilogue = EMPTYSTRING.join(epilogue)
            return
        # Otherwise, it's some non-multipart type, so the entire rest of the
        # file contents becomes the payload.
        lines = []
        for line in self._input:
            if line is NeedMoreData:
                yield NeedMoreData
                continue
            lines.append(line)
        self._cur.set_payload(EMPTYSTRING.join(lines))

    def _parse_headers(self, lines):
        # Passed a list of lines that make up the headers for the current msg
        lastheader = ''
        lastvalue = []
        for lineno, line in enumerate(lines):
            # Check for continuation
            if line[0] in ' \t':
                if not lastheader:
                    # The first line of the headers was a continuation.  This
                    # is illegal, so let's note the defect, store the illegal
                    # line, and ignore it for purposes of headers.
                    defect = errors.FirstHeaderLineIsContinuationDefect(line)
                    self._cur.defects.append(defect)
                    continue
                lastvalue.append(line)
                continue
            if lastheader:
                # XXX reconsider the joining of folded lines
                lhdr = EMPTYSTRING.join(lastvalue)[:-1].rstrip('\r\n')
                self._cur[lastheader] = lhdr
                lastheader, lastvalue = '', []
            # Check for envelope header, i.e. unix-from
            if line.startswith('From '):
                if lineno == 0:
                    # Strip off the trailing newline
                    mo = NLCRE_eol.search(line)
                    if mo:
                        line = line[:-len(mo.group(0))]
                    self._cur.set_unixfrom(line)
                    continue
                elif lineno == len(lines) - 1:
                    # Something looking like a unix-from at the end - it's
                    # probably the first line of the body, so push back the
                    # line and stop.
                    self._input.unreadline(line)
                    return
                else:
                    # Weirdly placed unix-from line.  Note this as a defect
                    # and ignore it.
                    defect = errors.MisplacedEnvelopeHeaderDefect(line)
                    self._cur.defects.append(defect)
                    continue
            # Split the line on the colon separating field name from value.
            i = line.find(':')
            if i < 0:
                defect = errors.MalformedHeaderDefect(line)
                self._cur.defects.append(defect)
                continue
            lastheader = line[:i]
            lastvalue = [line[i+1:].lstrip()]
        # Done with all the lines, so handle the last header.
        if lastheader:
            # XXX reconsider the joining of folded lines
            self._cur[lastheader] = EMPTYSTRING.join(lastvalue).rstrip('\r\n')
