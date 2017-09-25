(define (problem Belkan-problem)
   (:domain Belkan)
   (:objects
      ZONE_00_00 ZONE_00_01 ZONE_00_02 ZONE_00_03 ZONE_00_04 - zona
      ZONE_01_00 ZONE_01_01 ZONE_01_02 ZONE_01_03 ZONE_01_04 - zona
      ZONE_02_00 ZONE_02_01 ZONE_02_02 ZONE_02_03 ZONE_02_04 - zona
      ZONE_03_00 ZONE_03_01 ZONE_03_02 ZONE_03_03 ZONE_03_04 - zona
      ZONE_04_00 ZONE_04_01 ZONE_04_02 ZONE_04_03 ZONE_04_04 - zona
      norte sur este oeste - orientacion
      oscar rosa manzana algoritmo oro zapatillas bikini - objeto
      Princesa Principe Bruja Profesor LeonardoDiCaprio - personaje
      jugador1 - jugador
      Arena Piedra Agua Bosque Precipicio - tipoterreno
      mochila - mochila
	)
    (:init
      (posJugador jugador1 ZONE_00_00)
      (atJugador jugador1 este)
      (manoVacia jugador1)

      (posPersonaje Principe ZONE_01_04)
      (posPersonaje Princesa ZONE_02_00)
      (posPersonaje Bruja ZONE_03_01)
      (posPersonaje Profesor ZONE_00_02)
      (posPersonaje LeonardoDiCaprio ZONE_04_03)

      (posObjeto manzana ZONE_03_00)
      (posObjeto oscar ZONE_04_02)
      (posObjeto rosa ZONE_03_03)
      (posObjeto algoritmo ZONE_01_03)
      (posObjeto oro ZONE_01_01)
      (posObjeto zapatillas ZONE_00_03)
      (posObjeto bikini ZONE_01_02)

      ;; TIPOTERRENO
      (isZone ZONE_00_00 Arena)
      (isZone ZONE_00_01 Piedra)
      (isZone ZONE_00_02 Piedra)
      (isZone ZONE_00_03 Arena)
      (isZone ZONE_00_04 Precipicio)
      (isZone ZONE_01_00 Piedra)
      (isZone ZONE_01_01 Arena)
      (isZone ZONE_01_02 Piedra)
      (isZone ZONE_01_03 Piedra)
      (isZone ZONE_01_04 Agua)
      (isZone ZONE_02_00 Piedra)
      (isZone ZONE_02_01 Agua)
      (isZone ZONE_02_02 Agua)
      (isZone ZONE_02_03 Agua)
      (isZone ZONE_02_04 Agua)
      (isZone ZONE_03_00 Bosque)
      (isZone ZONE_03_01 Bosque)
      (isZone ZONE_03_02 Piedra)
      (isZone ZONE_03_03 Bosque)
      (isZone ZONE_03_04 Agua)
      (isZone ZONE_04_00 Precipicio)
      (isZone ZONE_04_01 Arena)
      (isZone ZONE_04_02 Bosque)
      (isZone ZONE_04_03 Arena)
      (isZone ZONE_04_04 Precipicio)

      ;; CONEXIONES
      (nextZoneInOrientation ZONE_00_00 sur ZONE_01_00)
      (nextZoneInOrientation ZONE_00_00 este ZONE_00_01)
      (nextZoneInOrientation ZONE_00_01 sur ZONE_01_01)
      (nextZoneInOrientation ZONE_00_01 oeste ZONE_00_00)
      (nextZoneInOrientation ZONE_00_01 este ZONE_00_02)
      (nextZoneInOrientation ZONE_00_02 sur ZONE_01_02)
      (nextZoneInOrientation ZONE_00_02 oeste ZONE_00_01)
      (nextZoneInOrientation ZONE_00_02 este ZONE_00_03)
      (nextZoneInOrientation ZONE_00_03 sur ZONE_01_03)
      (nextZoneInOrientation ZONE_00_03 oeste ZONE_00_02)
      (nextZoneInOrientation ZONE_00_03 este ZONE_00_04)
      (nextZoneInOrientation ZONE_00_04 sur ZONE_01_04)
      (nextZoneInOrientation ZONE_00_04 oeste ZONE_00_03)
      (nextZoneInOrientation ZONE_01_00 norte ZONE_00_00)
      (nextZoneInOrientation ZONE_01_00 sur ZONE_02_00)
      (nextZoneInOrientation ZONE_01_00 este ZONE_01_01)
      (nextZoneInOrientation ZONE_01_01 norte ZONE_00_01)
      (nextZoneInOrientation ZONE_01_01 sur ZONE_02_01)
      (nextZoneInOrientation ZONE_01_01 oeste ZONE_01_00)
      (nextZoneInOrientation ZONE_01_01 este ZONE_01_02)
      (nextZoneInOrientation ZONE_01_02 norte ZONE_00_02)
      (nextZoneInOrientation ZONE_01_02 sur ZONE_02_02)
      (nextZoneInOrientation ZONE_01_02 oeste ZONE_01_01)
      (nextZoneInOrientation ZONE_01_02 este ZONE_01_03)
      (nextZoneInOrientation ZONE_01_03 norte ZONE_00_03)
      (nextZoneInOrientation ZONE_01_03 sur ZONE_02_03)
      (nextZoneInOrientation ZONE_01_03 oeste ZONE_01_02)
      (nextZoneInOrientation ZONE_01_03 este ZONE_01_04)
      (nextZoneInOrientation ZONE_01_04 norte ZONE_00_04)
      (nextZoneInOrientation ZONE_01_04 sur ZONE_02_04)
      (nextZoneInOrientation ZONE_01_04 oeste ZONE_01_03)
      (nextZoneInOrientation ZONE_02_00 norte ZONE_01_00)
      (nextZoneInOrientation ZONE_02_00 sur ZONE_03_00)
      (nextZoneInOrientation ZONE_02_00 este ZONE_02_01)
      (nextZoneInOrientation ZONE_02_01 norte ZONE_01_01)
      (nextZoneInOrientation ZONE_02_01 sur ZONE_03_01)
      (nextZoneInOrientation ZONE_02_01 oeste ZONE_02_00)
      (nextZoneInOrientation ZONE_02_01 este ZONE_02_02)
      (nextZoneInOrientation ZONE_02_02 norte ZONE_01_02)
      (nextZoneInOrientation ZONE_02_02 sur ZONE_03_02)
      (nextZoneInOrientation ZONE_02_02 oeste ZONE_02_01)
      (nextZoneInOrientation ZONE_02_02 este ZONE_02_03)
      (nextZoneInOrientation ZONE_02_03 norte ZONE_01_03)
      (nextZoneInOrientation ZONE_02_03 sur ZONE_03_03)
      (nextZoneInOrientation ZONE_02_03 oeste ZONE_02_02)
      (nextZoneInOrientation ZONE_02_03 este ZONE_02_04)
      (nextZoneInOrientation ZONE_02_04 norte ZONE_01_04)
      (nextZoneInOrientation ZONE_02_04 sur ZONE_03_04)
      (nextZoneInOrientation ZONE_02_04 oeste ZONE_02_03)
      (nextZoneInOrientation ZONE_03_00 norte ZONE_02_00)
      (nextZoneInOrientation ZONE_03_00 sur ZONE_04_00)
      (nextZoneInOrientation ZONE_03_00 este ZONE_03_01)
      (nextZoneInOrientation ZONE_03_01 norte ZONE_02_01)
      (nextZoneInOrientation ZONE_03_01 sur ZONE_04_01)
      (nextZoneInOrientation ZONE_03_01 oeste ZONE_03_00)
      (nextZoneInOrientation ZONE_03_01 este ZONE_03_02)
      (nextZoneInOrientation ZONE_03_02 norte ZONE_02_02)
      (nextZoneInOrientation ZONE_03_02 sur ZONE_04_02)
      (nextZoneInOrientation ZONE_03_02 oeste ZONE_03_01)
      (nextZoneInOrientation ZONE_03_02 este ZONE_03_03)
      (nextZoneInOrientation ZONE_03_03 norte ZONE_02_03)
      (nextZoneInOrientation ZONE_03_03 sur ZONE_04_03)
      (nextZoneInOrientation ZONE_03_03 oeste ZONE_03_02)
      (nextZoneInOrientation ZONE_03_03 este ZONE_03_04)
      (nextZoneInOrientation ZONE_03_04 norte ZONE_02_04)
      (nextZoneInOrientation ZONE_03_04 sur ZONE_04_04)
      (nextZoneInOrientation ZONE_03_04 oeste ZONE_03_03)
      (nextZoneInOrientation ZONE_04_00 norte ZONE_03_00)
      (nextZoneInOrientation ZONE_04_00 este ZONE_04_01)
      (nextZoneInOrientation ZONE_04_01 norte ZONE_03_01)
      (nextZoneInOrientation ZONE_04_01 oeste ZONE_04_00)
      (nextZoneInOrientation ZONE_04_01 este ZONE_04_02)
      (nextZoneInOrientation ZONE_04_02 norte ZONE_03_02)
      (nextZoneInOrientation ZONE_04_02 oeste ZONE_04_01)
      (nextZoneInOrientation ZONE_04_02 este ZONE_04_03)
      (nextZoneInOrientation ZONE_04_03 norte ZONE_03_03)
      (nextZoneInOrientation ZONE_04_03 oeste ZONE_04_02)
      (nextZoneInOrientation ZONE_04_03 este ZONE_04_04)
      (nextZoneInOrientation ZONE_04_04 norte ZONE_03_04)
      (nextZoneInOrientation ZONE_04_04 oeste ZONE_04_03)

      ;; COSTES
      (= (coste ZONE_00_00 ZONE_01_00) 10)
      (= (coste ZONE_01_00 ZONE_00_00) 10)
      (= (coste ZONE_00_00 ZONE_00_01) 8)
      (= (coste ZONE_00_01 ZONE_00_00) 8)
      (= (coste ZONE_00_01 ZONE_01_01) 13)
      (= (coste ZONE_01_01 ZONE_00_01) 13)
      (= (coste ZONE_00_01 ZONE_00_02) 7)
      (= (coste ZONE_00_02 ZONE_00_01) 7)
      (= (coste ZONE_00_02 ZONE_01_02) 10)
      (= (coste ZONE_01_02 ZONE_00_02) 10)
      (= (coste ZONE_00_02 ZONE_00_03) 9)
      (= (coste ZONE_00_03 ZONE_00_02) 9)
      (= (coste ZONE_00_03 ZONE_01_03) 6)
      (= (coste ZONE_01_03 ZONE_00_03) 6)
      (= (coste ZONE_00_03 ZONE_00_04) 4)
      (= (coste ZONE_00_04 ZONE_00_03) 4)
      (= (coste ZONE_00_04 ZONE_01_04) 8)
      (= (coste ZONE_01_04 ZONE_00_04) 8)
      (= (coste ZONE_01_00 ZONE_02_00) 9)
      (= (coste ZONE_02_00 ZONE_01_00) 9)
      (= (coste ZONE_01_00 ZONE_01_01) 5)
      (= (coste ZONE_01_01 ZONE_01_00) 5)
      (= (coste ZONE_01_01 ZONE_02_01) 17)
      (= (coste ZONE_02_01 ZONE_01_01) 17)
      (= (coste ZONE_01_01 ZONE_01_02) 6)
      (= (coste ZONE_01_02 ZONE_01_01) 6)
      (= (coste ZONE_01_02 ZONE_02_02) 10)
      (= (coste ZONE_02_02 ZONE_01_02) 10)
      (= (coste ZONE_01_02 ZONE_01_03) 6)
      (= (coste ZONE_01_03 ZONE_01_02) 6)
      (= (coste ZONE_01_03 ZONE_02_03) 7)
      (= (coste ZONE_02_03 ZONE_01_03) 7)
      (= (coste ZONE_01_03 ZONE_01_04) 10)
      (= (coste ZONE_01_04 ZONE_01_03) 10)
      (= (coste ZONE_01_04 ZONE_02_04) 13)
      (= (coste ZONE_02_04 ZONE_01_04) 13)
      (= (coste ZONE_02_00 ZONE_03_00) 8)
      (= (coste ZONE_03_00 ZONE_02_00) 8)
      (= (coste ZONE_02_00 ZONE_02_01) 9)
      (= (coste ZONE_02_01 ZONE_02_00) 9)
      (= (coste ZONE_02_01 ZONE_03_01) 3)
      (= (coste ZONE_03_01 ZONE_02_01) 3)
      (= (coste ZONE_02_01 ZONE_02_02) 15)
      (= (coste ZONE_02_02 ZONE_02_01) 15)
      (= (coste ZONE_02_02 ZONE_03_02) 3)
      (= (coste ZONE_03_02 ZONE_02_02) 3)
      (= (coste ZONE_02_02 ZONE_02_03) 16)
      (= (coste ZONE_02_03 ZONE_02_02) 16)
      (= (coste ZONE_02_03 ZONE_03_03) 10)
      (= (coste ZONE_03_03 ZONE_02_03) 10)
      (= (coste ZONE_02_03 ZONE_02_04) 7)
      (= (coste ZONE_02_04 ZONE_02_03) 7)
      (= (coste ZONE_02_04 ZONE_03_04) 6)
      (= (coste ZONE_03_04 ZONE_02_04) 6)
      (= (coste ZONE_03_00 ZONE_04_00) 5)
      (= (coste ZONE_04_00 ZONE_03_00) 5)
      (= (coste ZONE_03_00 ZONE_03_01) 10)
      (= (coste ZONE_03_01 ZONE_03_00) 10)
      (= (coste ZONE_03_01 ZONE_04_01) 12)
      (= (coste ZONE_04_01 ZONE_03_01) 12)
      (= (coste ZONE_03_01 ZONE_03_02) 9)
      (= (coste ZONE_03_02 ZONE_03_01) 9)
      (= (coste ZONE_03_02 ZONE_04_02) 6)
      (= (coste ZONE_04_02 ZONE_03_02) 6)
      (= (coste ZONE_03_02 ZONE_03_03) 7)
      (= (coste ZONE_03_03 ZONE_03_02) 7)
      (= (coste ZONE_03_03 ZONE_04_03) 5)
      (= (coste ZONE_04_03 ZONE_03_03) 5)
      (= (coste ZONE_03_03 ZONE_03_04) 15)
      (= (coste ZONE_03_04 ZONE_03_03) 15)
      (= (coste ZONE_03_04 ZONE_04_04) 3)
      (= (coste ZONE_04_04 ZONE_03_04) 3)
      (= (coste ZONE_04_00 ZONE_04_01) 8)
      (= (coste ZONE_04_01 ZONE_04_00) 8)
      (= (coste ZONE_04_01 ZONE_04_02) 7)
      (= (coste ZONE_04_02 ZONE_04_01) 7)
      (= (coste ZONE_04_02 ZONE_04_03) 6)
      (= (coste ZONE_04_03 ZONE_04_02) 6)
      (= (coste ZONE_04_03 ZONE_04_04) 7)
      (= (coste ZONE_04_04 ZONE_04_03) 7)

      (= (camino) 0)
      (= (puntos) 0)

      (= (puntosPersonaje LeonardoDiCaprio oscar) 10)
      (= (puntosPersonaje LeonardoDiCaprio rosa) 1)
      (= (puntosPersonaje LeonardoDiCaprio manzana) 3)
      (= (puntosPersonaje LeonardoDiCaprio algoritmo) 4)
      (= (puntosPersonaje LeonardoDiCaprio oro) 5)

      (= (puntosPersonaje Princesa oscar) 5)
      (= (puntosPersonaje Princesa rosa) 10)
      (= (puntosPersonaje Princesa manzana) 1)
      (= (puntosPersonaje Princesa algoritmo) 3)
      (= (puntosPersonaje Princesa oro) 4)

      (= (puntosPersonaje Bruja oscar) 4)
      (= (puntosPersonaje Bruja rosa) 5)
      (= (puntosPersonaje Bruja manzana) 10)
      (= (puntosPersonaje Bruja algoritmo) 1)
      (= (puntosPersonaje Bruja oro) 3)

      (= (puntosPersonaje Profesor oscar) 3)
      (= (puntosPersonaje Profesor rosa) 4)
      (= (puntosPersonaje Profesor manzana) 5)
      (= (puntosPersonaje Profesor algoritmo) 10)
      (= (puntosPersonaje Profesor oro) 1)

      (= (puntosPersonaje Principe oscar) 1)
      (= (puntosPersonaje Principe rosa) 3)
      (= (puntosPersonaje Principe manzana) 4)
      (= (puntosPersonaje Principe algoritmo) 5)
      (= (puntosPersonaje Principe oro) 10)

      (= (capacidad mochila) 3)
      (= (usoMochila) 0)
	 )

    (:metric maximize (puntos))
    (:goal (AND (= (puntos) 30))
    )
)
