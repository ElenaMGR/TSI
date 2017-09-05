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
  )

  ;Ejercicio 1.c
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
    :parameters (?j - jugador ?o - orientacion ?z1 - zona ?z2 - zona)
    :precondition (and (atJugador ?j ?o) (posJugador ?j ?z1) (nextZoneInOrientation ?z1 ?o ?z2))
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
)
