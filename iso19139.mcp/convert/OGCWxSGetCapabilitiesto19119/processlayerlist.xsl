<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

	<xsl:output method="xml" indent="yes"/>

	<xsl:variable name="parents" as="node()">
		<parents>
			<parent prefix="ambis" uuid="b86c3aab-ec86-4671-95b6-3975156438bd">
				<xpath name=""></xpath>
			</parent>
		</parents>
	</xsl:variable>

  <xsl:template match="layers">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="$parents"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

  <xsl:template match="layer">
		<xsl:variable name="name" select="."/>
		<layer>
			<name><xsl:value-of select="$name"/></name>
			<parent>
				<xsl:variable name="prefix" select="substring-before($name,':')"/>
				<xsl:value-of select="$parents/parent[@prefix=$prefix]/@uuid"/>
			</parent>
		</layer>
	</xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
