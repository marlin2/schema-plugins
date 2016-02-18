<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
	xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gml="http://www.opengis.net/gml"
	xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wfs="http://www.opengis.net/wfs"
	xmlns:wms="http://www.opengis.net/wms"
	xmlns:ows="http://www.opengis.net/ows" xmlns:wcs="http://www.opengis.net/wcs"
	xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
	xmlns:xlink="http://www.w3.org/1999/xlink" extension-element-prefixes="wcs ows wfs srv">


	<xsl:template name="addXlink">
		<xsl:param name="element"/>
		<xsl:param name="parentmatch"/>
		<xsl:param name="metadatasubtemplateurl"/>

		<xsl:message>Looking for element <xsl:value-of select="$element"/> in <xsl:copy-of select="$parentmatch"/></xsl:message>
		<elements>

		<xsl:if test="count($parentmatch/xpathid[normalize-space()=$element])>0">
			<xsl:for-each select="$parentmatch/xpathid[normalize-space()=$element]">
				<xsl:if test="normalize-space()=$element">
					<xsl:message>XLink URL: <xsl:value-of select="concat($metadatasubtemplateurl,../@uuid,@id)"/></xsl:message>
					<xsl:element name="{$element}">
						<xsl:attribute name="xlink:href"><xsl:value-of select="concat($metadatasubtemplateurl,../@uuid,@id)"/></xsl:attribute>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

		</elements>
	</xsl:template>

	<xsl:template name="addCodedContent">
		<xsl:param name="element"/>
		<xsl:param name="parentmatch"/>
		<xsl:param name="layermatch"/>

		<xsl:message>AddCodedContent: In parent <xsl:value-of select="count($parentmatch/*[name()=$element])"/> in Layer: <xsl:value-of select="count($layermatch/*[name()=$element])"/></xsl:message>
		<elements>
			<xsl:if test="count($layermatch/*[name()=$element])>0 or count($parentmatch/*[name()=$element])>0">
				<xsl:element name="{$element}">
					<gco:CharacterString><xsl:value-of select="concat($layermatch/*[name()=$element],' ',$parentmatch/*[name()=$element])"/></gco:CharacterString>
				</xsl:element>
			</xsl:if>
		</elements>
	</xsl:template>

</xsl:stylesheet>
