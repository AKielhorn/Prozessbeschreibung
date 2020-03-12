# Motivation

Anfang 2019 hat mein damaliger Arbeitgeber Prozessbeschreibungen definiert, um 
Kernprozesse eindeutig zu beschreiben. Da der Betrieb mit MS-Office arbeitet, 
wurden die Beschreibungen als Office Dateien erstellt. Wie es bei interaktiven 
Programmen üblich ist, war hier viel Handarbeit erforderlich, um die 
Beziehungen der Prozesse untereinander zu ermitteln und darzustellen.

Also dachte ich mir, das müsste man doch automatisieren können.

Zuerst müssen die Daten von Büro 3.0 in Büro 4.0 überführt werden.[^FN]

[^FN]: Büro 1.0 -- Handschriftlich auf Papier, Büro 2.0 -- Schreibmaschine auf 
Papier (optional mit Durchschlägen), Büro 3.0 -- Computer mit Drucker, Büro 4.0 
-- Strukturierte Daten, die von anderen Programmen verstanden werden.

Als Format habe ich XML gewählt, da man es problemlos mit einem Editor 
schreiben kann und es in den gängigen Programmiersprachen Bibliotheken gibt, um 
es einzulesen. 

Damit die XML-Dateien validiert werden können, habe ich entsprechende DTDs dazu 
erstellt. So kann ich bei der Weiterverarbeitung von validen Daten ausgehen.

# Dokumentorientierter Ablauf

Die Schnittstellen zwischen den Prozessen bestehen aus Dokumenten.
Entweder benötigt ein Prozess ein Dokument, oder er erzeugt es.

Alle Dokumente werden in der Datei `doclist.xml` aufgeführt und durch eine 
Dokumentennummer eindeutig identifiziert. (Die Nummer kann auch alphanumerisch 
sein.)

In der Prozessbeschreibung wird für jeden Prozessschritt angegeben, welche 
Dokumente benötigt oder erzeugt werden. Dabei wird nur die Dokumentennummer 
angegeben.

Das Programm `panalyse.lua` ließt eine Prozessbeschreibung ein und ergänzt in 
der Dokumentliste die entsprechenden Beziehungen. Grundsätzlich kann ein 
Dokument mehrere Empfänger haben, die aktuelle Implementierung berücksichtigt 
das noch nicht.

Sollt ein unbekanntes Dokument auftauchen, so wird es ebenfalls in die 
Dokumentliste übernommen.

Nachdem alle Prozessbeschreibungen einmal mit `panalyse` analysiert wurden, 
sollten alle Beziehungen in der Dokumentliste enthalten sein.

Nun kann die Dokumentliste ausgedruckt werden.
Sie zeigt den Informationsfluss zwischen den Prozessen.

Beim Ausdruck der Prozessbeschreibung werden die Beziehungen aus der 
Dokumentliste gelesen und in die Prozessbeschreibung übernommen.

# Neue Räder?

Das gibt es doch schon, allerdings nicht von Bosch sondern von IBM.

Mit BPMN (Business Process Model and Notation) gibt es bereits ein Werkzeug zur 
grafischen Darstellung von Prozessen. Es benutzt sogar XML!

Da grafische ist dabei genau mein Problem.
Natürlich kann man viele Ikons mit Pfeilen verbinden und so eine 
Prozesslandkarte erstellen, allerdings wir sie bei nicht trivialen Prozessen 
schnell sehr groß und unübersichtlich, oder die Prozesse werden zu stark 
vereinfacht und die Übersicht somit aussagelos.

Trotzdem habe ich versucht eine grafische Darstellung zu erzeugen, allerdings 
manuell und in LaTeX. Der Informationsgewinn ist im Vergleich zum Aufwand 
gering, daher habe ich von eine Portierung nach ConTeXt abgesehen.

# Voraussetzungen

Die hier beschriebenen Programme nutzen [ConTeXt Mark 
IV](https://wiki.contextgarden.net/Main_Page).

ConTeXt wurde gewählt, da es mit unter 400 MB deutlich kleiner ist, als eine 
TeX-Live Installation. Außerdem bietet ConTeXt einen einfachen Zugang zur 
Programmierung in Lua, somit ist keine zusätzliche Installation erforderlich.

# Prozessbeschreibung

Der Prozess wird in einer XML-Datei beschrieben.
Diese kann gegen die beiliegende DTD-Datei validiert werden.

Die ConTeXt Environment `prozess-style.tex` formatiert die XML-Datei für DIN A4 
Querformat.

~~~
context --environment=prozess-style.tex prozess.xml
~~~

Dabei werden die Dokumentnamen und die Empfänger aus der Datei `doclist.xml` 
geladen.

# Dokumentliste

Aus der Datei `doclist.xml` kann eine Liste aller Dokumente und der 
dazugehörigen Abhängigkeiten erstellt werden.

~~~
context --environment=doclist-style.tex doclist.xml
~~~

# Prozessanalyse

Damit man die Abhängigkeiten nicht von Hand ermitteln muss, analysiert das 
Programm `panalyse.lua` die einzelnen Prozessbeschreibungen und trägt sie in 
eine XML-Datei vom Typ `doclist.dtd` ein. Dabei werden nur Abhängigkeiten 
*hinzugefügt*. Die Dokumentnamen müssen dann bei Bedarf manuell ergänzt werden.

Aufruf mit

~~~
mtxrun --script panalyse.lua doclist.xml prozess.xml outfile.xml > p.err
~~~

 -  `doclist.xml` muss eine valide XML Datei vom Typ doclist.dtd sein.
 -  `prozess.xml` muss eine valide XML Datei vom Typ prozess.dtd sein.

Werden keine Argumente angegeben, so werden die Dateinamen
doclist.xml und prozess.xml benutzt.

Das Ergebnis wird in outfile.xml gespeichert.
Diese Datei ist eine valide XML-Datei vom Typ doclist.xml.

Die aktuelle Version kann nur einen Empfänger pro Dokument verarbeiten.

Die grafische Darstellung `prozess-visualisierung.tex` wird noch *nicht* 
automatisch erzeugt.

# Zukunft

 -  Dokumente mit mehreren Empfängern werden noch nicht berücksichtigt.
 -  Aufzeichnungen: Ein Ersteller, viele Aktualisierer.
 -  Programm zum Löschen der Beziehungen aus der `doclist`
 -  Schalter für Außendarstellung (nur Prozesschritte) und vollständigen 
    Prozess mit Arbeitsschritten. (ConTeXt mode)

# Lizenz

Die Programme in diesem Projekt sind unter GPL Version 3 lizenziert.

Die Daten in diesem Projekt sind unter Creative Commons CC BY 4.0 lizenziert.


