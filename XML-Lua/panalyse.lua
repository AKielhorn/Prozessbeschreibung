local application = logs.application {
    name     = "Prozess",
    banner   = "Prozess parser",
}
--[[
Aufruf mit
mtxrun --script panalyse.lua doclist.xml prozess.xml outfile.xml > p.err

doclist.xml muss eine valide XML Datei vom Typ doclist.dtd sein.
prozess.xml muss eine valide XML Datei vom Typ prozess.dtd sein.

Das Ergebnis wird in outfile.xml gespeichert.
Diese Date ist eine valide XML-Datei vom Typ doclist.xml.

Werden keine Argumente angegeben, so werden die Dateinamen
doclist.xml, prozess.xml und outfile.xml benutzt.

Vereinfachung:
Laut Spezifikation kann es zu einem Dokument mehrer DOCAN geben.
Das wird zur Zeit nicht unterstützt, der letzte Empfänger gewinnt.

Musik:
- Safri Duo

--]]

local report = application.report

-- String in XML template ersätzen.

local replacetemplate = utilities.templates.replace
local striplines = utilities.strings.striplines
-- local xmltext = xml.text
local xmlfilter = xml.filter

t_doc = [[
<psdoc>
	<docnr> %docnr% </docnr>
	<docname> %docname% </docname>
	<docverantwortlich> %docverantwortlich% </docverantwortlich>
	<docan> %docan% </docan>
</psdoc>
]]

doclistheader = [[
<?xml version="1.0"?>
<!DOCTYPE prozess SYSTEM "doclist.dtd">
<!-- 
% Copyright 2019 Axel Kielhorn
% Lizenz: CC-BY-SA 4.0 Unported http://creativecommons.org/licenses/by-sa/4.0/deed.de
-->
<doclist>
]]

doclistfooter = [[
</doclist>
]]

local settings = {}
local docstruktur = {}
-- docstruktur[docnr]
--	docname
--	docan
--	docverantwortlich

if arg[1] then
	doclistfile = arg[1]
else
	doclistfile = "doclist.xml"
end

if arg[2] then
	prozessfile = arg[2]
else
	prozessfile = "prozess.xml"
end

if arg[3] then
	outfile = arg[3]
else
	outfile = "outfile.xml"
end
--
-- Hilfsfunktionen


-- Daten in Dokumentstruktur einpflegen
-- docan sollte ein table sein, da mehrer Empfänger möglich sind

docadd = function(docnr, wie, wer)
	-- print (docnr, wie, wer)
	if not docstruktur[docnr] then
		docstruktur[docnr] = {}
	end
	if wie == "an" then
		docstruktur[docnr]["docan"] = wer
	end
	if wie == "ver" then
		docstruktur[docnr]["docverantwortlich"] = wer
	end
end

-- doclist.xml in docstruktur einlesen

doc = xml.load(doclistfile, settings)

for v in xml.collected(doc,"/doclist/psdoc/") do
	local docnr = striplines(xmlfilter(v,"/docnr/text()"))
	local docname = striplines(xmlfilter(v,"/docname/text()"))
	-- es kann mehrere DOCAN geben!
	local docan = striplines(xmlfilter(v,"/docan/text()"))
	local docverantwortlich = striplines(xmlfilter(v,"/docverantwortlich/text()"))
	docstruktur[docnr]={
	    docname = docname,
	    docan = docan,
	    docverantwortlich = docverantwortlich
        }
end

-- prozess.xml einlesen
-- Einträge in doclist erweitern

prozess = xml.load(prozessfile, settings)
pverantwortlich = (striplines(xmlfilter(prozess,"/pverantwortlich/text()")))
for v in xml.collected(prozess,"/prozess/pschritt/") do
	local psnr = striplines(xmlfilter(v,"/psnr/text()"))
	-- PSINDOC: welche Dokumente benötige ich?
	local psindoc = xmlfilter(v,"/psindoc/all()")
	for j,w in ipairs(psindoc) do
		docnr = striplines(xmlfilter(w,"/docnr/text()"))
		-- DOCVERANWORTLICH wird hier nicht benötigt.
		docver = striplines(xmlfilter(w,"/docverantwortlich/text()"))
		docadd (docnr, "an", pverantwortlich)
	end
	-- PSOUTDOC: Welche Dokumente erzeuge ich?
	local psoutdoc = xmlfilter(v,"/psoutdoc/all()")
	for j,w in ipairs(psoutdoc) do
		docnr = striplines(xmlfilter(w,"/docnr/text()"))
		-- DOCAN wird hier nicht benötigt.
		docan = striplines(xmlfilter(w,"/docan/text()"))
		docadd (docnr, "ver", pverantwortlich)
	end
end

-- XML ausgeben 

docstrukturxml = ""

for k, v in pairs(docstruktur) do
	psoutxml = replacetemplate(t_doc, {
		docnr = k,
		docname = v["docname"],
		docan = v["docan"],
		docverantwortlich = v["docverantwortlich"],
	} )
	docstrukturxml = docstrukturxml .. psoutxml
end
docstrukturxml = doclistheader .. docstrukturxml .. doclistfooter

io.savedata(outfile, docstrukturxml)

-- So far no logging
--[[
local f = io.open("p.log", "w")
f:write()
f:close()
--]]
