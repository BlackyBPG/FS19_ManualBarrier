# FS19_ManualBarrier
![ManualBarrier Ingame](https://github.com/BlackyBPG/FS19_ManualBarrier/blob/master/logo_ManualBarrier.png "ManualBarrier Logo")

ManualBarrier ist für Karten-Ersteller gedacht die viele unterschiedliche Objekte auf ihrer Karte entweder manuell oder automatisch in Bewegung versetzen wollen.
Eigentlich täuscht der Name denn dieses Paket kann weitaus mehr als nur eine Schranke manuell zu bedienen.

Egal ob nun ein Schiebetor, eine Schwingtür, eine Schranke oder gar ein komplex animiertes Objekt in Bewegung versetzt werden muss, manuell oder automatisch spielt dabei keine Rolle, oder ob es sich um einschaltbare Lichtquellen oder sonstiges handelt. Für all dies kann ManualBarrier verwendet werden.

Im Grunde kann ManualBarrier für so gut wie jedes Objekt verwendet werden, naja auf jeden Fall für die meisten ;)

Und dabei ist es sehr vielfältig, alles kann miteinander kombiniert werden, ob Rotation und Bewegung oder Animation und Licht, oder auch alles zusammen, ob man nun eine alte Leuchtstoffröhre mit dem typischen Einschaltflackern haben möchte oder ein Rundumlicht bei Schiebetoröffung. Man will den Zugang zu einem Ort nur zu einer bestimmten Uhrzeit gewähren? Kein Problem, auch das kann ManualBarrier. Automatisches Hoflicht ab 20 Uhr? Warum nicht, ManualBarrier macht auch dies einfach.

Selbstverständlich ist ManualBarrier auch für den Multiplayer-Modus von LS19 geeignet, jede Funktion wird dabei voll unterstützt ebenso wie die Zuordnung zu den Farmen.

Für den genauen Einbau folgen eine Erklärung der User Attribute, ein Beispielaufbau im I3D-Editor Scenegraphen sowie die nötigen Einträge in der modDesc.xml.

Grundsätzlich setze ich jedoch Kenntnisse mit dem Giants-Editor sowie der XML-Bearbeitung voraus damit ManualBarrier Verwendung finden kann.

------------

#### Inhalt des Paketes

Im Archiv sind verschiedene Schranken, Rolltore und andere Objekte enthalten welche allesamt über ManualBarrier gesteuert werden können und bereits dafür vorbereitet sind.
Des weiteren sind im Archiv die LiesMich (und ReadMe) enthalten die eine genaue Beschreibung der UserAttribute auflisten und die Funktionsweise dieser.

------------

#### Features

- Ein großes Dankeschön geht an Luan Löwe vom ProjektMecklenburg (Kandelin/Kemnitz) für das bereitstellen eines Testservers sowie für das Testen der Mutliplayer-Funktiionen.
- - manuelle oder automatische Öffnung
- - Rotation (Drehbewegung), Translation (Seitenbewegung), animierte Objekte, Einblendungen
- - verschiedene Modi für alle Objekte
- - - flackern beim einschalten einer Lichtquelle
- - - einschaltbare Objekte nur während der Bewegung oder an/aus
- - - Audiowiedergabe während der Bewegung möglich
- - - Audiowiedergabe in Schleife bei voller Öffnung und/oder voller Schließung
- - - automatisches schließen nach manueller Öffnung möglich
- - - zeitgesteuertes Öffnen und Schließen
- - - Beschränkung der manuellen Öffnung auf mehrere bestimmte Zeiträume möglich
- - - Kombination mehrerer Bewegungsabläufe (Rotation,Translation,Animation) möglich
- - - individuelle Geschwindigkeitseinstellungen möglich
- - - individuelle Namensvergabe der Objekte sowie an/aus Funktionen (siehe Screenshots)
- - - individuelle Achsauswahl möglich, Kombinationen mehrerer Achsen ebenfalls
- - - speichern/laden des Öffnungszustandes von manuell gesteuerten Objekten im/vom Savegame
- - - zufällige Schließungen möglich
- - - Reaktion auf KI-Traffic-Fahrzeuge
- - Bindung an eine Farm möglich
- - vollständig Multiplayer kompatibel
- - automatische Sperre bei Regen möglich

------------

------------

#### CHANGELOG:

- ##### Version 1.9.0.7 (09.02.2020)
- - add loopOnClose for animated objects
- - add loopOnOpen for animated objects
- - add playFull for animated objects

- ##### Version 1.9.0.6 (26.12.2019)
- - add workaround for enterable/playerstyle error

- ##### Version 1.9.0.5 (21.12.2019)
- - fix non working farm restricted on manualOpen

- ##### Version 1.9.0.4 (16.12.2019)
- - fix error on saving random event barrier

- ##### Version 1.9.0.3 (14.12.2019)
- - fix missing message on random closed triggers

- ##### Version 1.9.0.2 (12.12.2019)
- - fix error on enter trigger with weight

- ##### Version 1.9.0.1 (08.12.2019)
- - Initial converted Release for Fs19

------------

------------

[ManualBarrier ReadMe (DE)](https://github.com/BlackyBPG/FS19_ManualBarrier/blob/master/LiesMich.pdf "ManualBarrier ReadMe (DE)")