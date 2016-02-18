<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
		xmlns:app="http://www.deegree.org/app"
		xmlns:gco="http://www.isotc211.org/2005/gco"
		xmlns:grg="http://www.isotc211.org/2005/grg"
		xmlns:gnreg="http://geonetwork-opensource.org/register"
		xmlns:gmd="http://www.isotc211.org/2005/gmd"
		xmlns:gmx="http://www.isotc211.org/2005/gmx"
		xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
		xmlns:gml="http://www.opengis.net/gml"
		xmlns:wfs="http://www.opengis.net/wfs"
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"		
		xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

	<!-- 
			 This xslt transforms GetFeature outputs from the WFS Marlin database
	     into ISO metadata fragments. The fragments are used by GeoNetwork to 
			 build ISO metadata records.
	 -->

	<xsl:template match="/wfs:FeatureCollection">
		<records>
			<xsl:message>Processing <xsl:value-of select="@numberOfFeatures"/></xsl:message>
			<xsl:if test="boolean( ./@timeStamp )">
				<xsl:attribute name="timeStamp">
					<xsl:value-of select="./@timeStamp"></xsl:value-of>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="boolean( ./@lockId )">
				<xsl:attribute name="lockId">
					<xsl:value-of select="./@lockId"></xsl:value-of>
				</xsl:attribute>
			</xsl:if>

			<xsl:variable name="regions">
				<regions>
					<xsl:for-each select="//app:DefinedRegions">
						<xsl:variable name="countSeps" select="string-length(app:defined_region_name) - string-length(translate(app:defined_region_name, '>', ''))"/>
						<region id="{app:defined_region_id}" name="{app:defined_region_name}" count="{$countSeps}"/>
					</xsl:for-each>
				</regions>
			</xsl:variable>

			<!-- <xsl:message><xsl:copy-of select="$regions"/></xsl:message> -->

			<xsl:variable name="hierarchy">
				<hierarchy>
				<xsl:for-each-group select="$regions/regions/region" group-by="@count">
					<xsl:for-each select="current-group()">
						<xsl:variable name="starts" select="@name"/>
						<xsl:copy copy-namespaces="no">
							<xsl:copy-of select="@*"/>
							<xsl:if test="current-grouping-key() != 2">
								<xsl:for-each select="$regions/regions/region[@count=current-grouping-key()+1 and starts-with(@name,$starts)]">
									<child id="{@id}" name="{@name}"/>
								</xsl:for-each>
							</xsl:if>
						</xsl:copy>
					</xsl:for-each>
				</xsl:for-each-group>
				</hierarchy>
			</xsl:variable>

			<xsl:variable name="uuid" select="'urn:marlin.csiro.au:DefinedRegions'"/>

			<record uuid="{$uuid}">
				<replacementGroup id="register_item">
					<xsl:apply-templates select="gml:featureMember">
						<xsl:with-param name="uuid" select="$uuid"/>
						<xsl:with-param name="hierarchy" select="$hierarchy"/>
					</xsl:apply-templates>
				</replacementGroup>
			</record>
		</records>
	</xsl:template>

	<xsl:template match="*[@xlink:href]" priority="20">
		<xsl:variable name="linkid" select="substring-after(@xlink:href,'#')"/>
		<xsl:apply-templates select="//*[@gml:id=$linkid]"/>
	</xsl:template>

	<!-- process a record from the MarLIN define_regions table -->
	<xsl:template name="addDefineRegionsRegisterItem">
		<xsl:param name="keywordUuid"/>
		<xsl:param name="hierarchy" as="node()"/>
		<fragment id="register_item" uuid="{$keywordUuid}" title="{app:defined_region_name}">
			<grg:containedItem>
				<gnreg:RE_RegisterItem>
					<grg:itemIdentifier>
						<gco:Integer><xsl:value-of select="app:defined_region_id"/></gco:Integer>
					</grg:itemIdentifier>
					<grg:name>
						<gco:CharacterString>
							<xsl:value-of select="app:defined_region_name"/>
						</gco:CharacterString>
					</grg:name>
					<grg:status>
						<grg:RE_ItemStatus>valid</grg:RE_ItemStatus>
					</grg:status>
					<grg:dateAccepted>
						<gco:Date>2015-02-18</gco:Date>
					</grg:dateAccepted>
					<grg:definition>
						<gco:CharacterString>
							<xsl:value-of select="app:defined_region_id"/>
						</gco:CharacterString>
					</grg:definition>
					<grg:fieldOfApplication>
						<grg:RE_FieldOfApplication>
							<grg:name>
								<gco:CharacterString>CSIRO Oceans and Atmosphere Metadata</gco:CharacterString>
							</grg:name>
							<grg:description>
								<gco:CharacterString>CSIRO Oceans and Atmosphere Metadata</gco:CharacterString>
							</grg:description>
						</grg:RE_FieldOfApplication>
					</grg:fieldOfApplication>
          <grg:additionInformation>
            <grg:RE_AdditionInformation>
               <grg:dateProposed>
                  <gco:Date>2012-06-30</gco:Date>
               </grg:dateProposed>
               <grg:justification>
                  <gco:CharacterString>Assembling ISO19135 register to describe this thesaurus</gco:CharacterString>
               </grg:justification>
               <grg:status>
                  <grg:RE_DecisionStatus>final</grg:RE_DecisionStatus>
               </grg:status>
               <grg:sponsor xlink:href="#CMAR_Submitter"/>
            </grg:RE_AdditionInformation>
          </grg:additionInformation>
					<xsl:variable name="id" select="app:defined_region_id"/>
					<xsl:for-each select="$hierarchy/hierarchy/region[@id=$id]/child">
						<grg:specificationLineage>
              <grg:RE_Reference>
               	<grg:itemIdentifierAtSource>
                  <gco:CharacterString><xsl:value-of select="@id"/></gco:CharacterString>
                </grg:itemIdentifierAtSource>
                <grg:similarity>
                  <grg:RE_SimilarityToSource codeListValue="specialization"
                                             codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#RE_SimilarityToSource"/>
                </grg:similarity>
              </grg:RE_Reference>
            </grg:specificationLineage>
					</xsl:for-each>
					<gnreg:itemIdentifier>
						<gco:CharacterString><xsl:value-of select="$keywordUuid"/></gco:CharacterString>
					</gnreg:itemIdentifier>
					<gnreg:itemExtent>
						<gmd:EX_Extent>

					<gmd:geographicElement>
            <gmd:EX_GeographicBoundingBox>
              <gmd:westBoundLongitude>
                <gco:Decimal><xsl:value-of select="app:west_bounding_coordinate"/></gco:Decimal>
              </gmd:westBoundLongitude>
              <gmd:eastBoundLongitude>
                <gco:Decimal><xsl:value-of select="app:east_bounding_coordinate"/></gco:Decimal>
              </gmd:eastBoundLongitude>
              <gmd:southBoundLatitude>
                <gco:Decimal><xsl:value-of select="app:south_bounding_coordinate"/></gco:Decimal>
              </gmd:southBoundLatitude>
              <gmd:northBoundLatitude>
                <gco:Decimal><xsl:value-of select="app:north_bounding_coordinate"/></gco:Decimal>
              </gmd:northBoundLatitude>
            </gmd:EX_GeographicBoundingBox>
          </gmd:geographicElement>	

						</gmd:EX_Extent>
					</gnreg:itemExtent>
				</gnreg:RE_RegisterItem>
			</grg:containedItem>
		</fragment>
	</xsl:template>

	<!-- process the featureMember elements in WFS response -->
	<xsl:template match="gml:featureMember">
		<xsl:param name="uuid"/>
			<xsl:param name="hierarchy" as="node()"/>
		
		<xsl:apply-templates select="app:DefinedRegions">
			<xsl:with-param name="uuid" select="$uuid"/>
			<xsl:with-param name="hierarchy" select="$hierarchy"/>
		</xsl:apply-templates>

	</xsl:template>

	<!-- process the DefinedRegions in WFS response -->
	<xsl:template match="app:DefinedRegions">
			<xsl:param name="uuid"/>
			<xsl:param name="hierarchy" as="node()"/>

			<xsl:call-template name="addDefineRegionsRegisterItem">
				<xsl:with-param name="keywordUuid" select="concat($uuid,':concept:',app:defined_region_id)"/>
				<xsl:with-param name="hierarchy" select="$hierarchy"/>
			</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>
