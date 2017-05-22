(define (domain monkey-domain)	       ; Comment: adding location caused fail
  (:requirements :strips :equality :typing)
  (:types  monkey banana box - locatable
          location)

  (:predicates
	       (on-floor ?x - monkey )
	       (at ?m - locatable ?x - location)
	       (onbox ?x - monkey ?y - location)
	       (hasbananas ?x - monkey)

	       )
  (:action GRAB-BANANAS
	     :parameters (?m - monkey ?y - location)
	     :precondition (and (onbox ?m  ?y))
	     :effect (hasbananas ?m))

   (:action CLIMB-BOX
         :parameters(?x - monkey ?p - banana ?b - box ?l - location )
         :precondition (and (at ?x ?l) (at ?b ?l) (at ?p ?l))
         :effect (
            and (not(on-floor ?x) (onbox ?x ?l))
            ))
)
