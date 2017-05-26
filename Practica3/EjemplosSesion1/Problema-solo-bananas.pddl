(define (problem monkey-test1)
    (:domain monkey-domain)
    (:objects p1 p2 p3 p4 - location
            monkey1 - monkey
			   box1 - box
			   bananas1 - banana)
    (:init
         (at monkey1 p1)
	      (on-floor monkey1)
         (at box1 p2)
         (at bananas1 p3)
	 )
    (:goal (AND (hasbananas monkey1))))
