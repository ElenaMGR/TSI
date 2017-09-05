(define (domain Belkan)
  (:requirements
    :strips :equality :typing :fluents
  )

  (:types
    jugador
    orientacion
    personaje
    objeto
    zona
    tipoterreno
    mochila
  )

  ;Añadir coste
  (:functions
    (camino)
    (coste ?a ?b - zona)
  )

  (:predicates
     ;Conexión entre zonas
     (nextZoneInOrientation ?z1 - zona ?o - orientacion ?z2 - zona)
     ;Orientacion del jugador
     (atJugador ?j - jugador ?o - orientacion)
     ;Posición del objeto
     (posObjeto ?o - objeto ?z - zona )
     ;Posicion del jugador
     (posJugador ?j - jugador ?z - zona )
     ;Posicion del personaje
     (posPersonaje ?p - personaje ?z - zona)
     ;El jugador tiene la mano vacía
     (manoVacia ?j - jugador)
     ;El jugador lleva un objeto
     (manoLlena ?j - jugador ?o - objeto)
     ;Que un objeto ya haya sido entregado a su personaje
     (entregado ?p - personaje)
     ;La mochila esta vacía
     (mochilaVacia ?m - mochila)
     ;La mochila tiene un objeto
     (mochilaLlena ?m - mochila ?o - objeto)
     ;Tipo de terreno
     (isZone ?z - zona ?t - tipoterreno)
  )

  ;Girar a la izquierda
  (:action GirarIzquierda
    :parameters (?j - jugador ?o - orientacion)
    :precondition (atJugador ?j ?o)
    :effect (and
      (when (= ?o norte) (and (not(atJugador ?j ?o))(atJugador ?j oeste)))
      (when (= ?o este) (and (not(atJugador ?j ?o))(atJugador ?j norte)))
      (when (= ?o sur) (and (not(atJugador ?j ?o))(atJugador ?j este)))
      (when (= ?o oeste) (and (not(atJugador ?j ?o))(atJugador ?j sur)))
    )
  )

  ;Girar a la derecha
  (:action GirarDerecha
    :parameters (?j - jugador ?o - orientacion)
    :precondition (atJugador ?j ?o)
    :effect (and
      (when (= ?o norte) (and (not(atJugador ?j ?o))(atJugador ?j este)))
      (when (= ?o este) (and (not(atJugador ?j ?o))(atJugador ?j sur)))
      (when (= ?o sur) (and (not(atJugador ?j ?o))(atJugador ?j oeste)))
      (when (= ?o oeste) (and (not(atJugador ?j ?o))(atJugador ?j norte)))
    )
  )

  ;Ir de una zona a otra correctamente orientado
  (:action Ir
    :parameters (?j - jugador ?o - orientacion ?z1 - zona ?z2 - zona ?t - tipoterreno ?m - mochila)
    :precondition
      (and
         (atJugador ?j ?o) (posJugador ?j ?z1) (nextZoneInOrientation ?z1 ?o ?z2) (isZone ?z2 ?t) (not (= ?t Precipicio))
            (or
               (and (= ?t Bosque) (or (manoLlena ?j zapatillas) (mochilaLlena ?m zapatillas)))
               (and (= ?t Agua) (or (manoLlena ?j bikini) (mochilaLlena ?m bikini)))
               (and (or (= ?t Piedra) (= ?t Arena)))
            )
      )
    :effect (and (not (posJugador ?j ?z1)) (posJugador ?j ?z2) (increase (camino) (coste ?z1 ?z2)))
  )

  ;Coger objeto
  (:action Coger
    :parameters (?j - jugador ?z - zona ?o - objeto)
    :precondition (and (PosJugador ?j ?z) (posObjeto ?o ?z) (manoVacia ?j))
    :effect (and (not (manoVacia ?j)) (manoLlena ?j ?o) (not (posObjeto ?o ?z)))
  )

  ;Dejar objeto
  (:action Dejar
    :parameters (?j - jugador ?z - zona ?o - objeto)
    :precondition (and (manoLlena ?j ?o) (posJugador ?j ?z))
    :effect (and (not (manoLlena ?j ?o)) (manoVacia ?j) (posObjeto ?o ?z))
  )

  ;Entregar objeto a personaje
  (:action Entregar
    :parameters (?o - objeto ?p - personaje ?z - zona ?j - jugador)
    :precondition (and (posJugador ?j ?z) (posPersonaje ?p ?z) (manoLlena ?j ?o))
    :effect(and (not (manoLlena ?j ?o)) (manoVacia ?j) (entregado ?p))
  )

  ;Guardar objeto en la mochila
  (:action Guardar
     :parameters (?j - jugador ?m - mochila ?o - objeto)
     :precondition (and (mochilaVacia ?m) (manoLlena ?j ?o))
     :effect (and (not (mochilaVacia ?m)) (mochilaLlena ?m ?o) (manoVacia ?j) (not (manoLlena ?j ?o)))
  )

  ;Sacar objeto de la mochila
  (:action Sacar
     :parameters (?j - jugador ?m - mochila ?o - objeto)
     :precondition (and (manoVacia ?j) (mochilaLlena ?m ?o))
     :effect (and (manoLlena ?j ?o) (not (manoVacia ?j)) (not (mochilaLlena ?m ?o)) (mochilaVacia ?m))
  )

)
