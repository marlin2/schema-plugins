<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
	xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gml="http://www.opengis.net/gml"
	xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wfs="http://www.opengis.net/wfs"
	xmlns:wms="http://www.opengis.net/wms"
	xmlns:ows="http://www.opengis.net/ows" xmlns:wcs="http://www.opengis.net/wcs"
	xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
	xmlns:xlink="http://www.w3.org/1999/xlink" extension-element-prefixes="wcs ows wfs srv">

	<!--
		=============================================================================
	-->

	<xsl:param name="uuid" />
	<xsl:param name="Name" />
	<xsl:param name="lang" />
	<xsl:param name="topic" />

	<xsl:variable name="layermap" select="document('layerlistmap.xml')"/> 


	<!-- Max number of coordinate system to add
	to the metadata record. Avoid to have too many CRS when 
	OGC server list all epsg database. -->
	<xsl:variable name="maxCRS">21</xsl:variable>

	<!--
		=============================================================================
	-->

	<xsl:include href="addxlinks.xsl" />
	<xsl:include href="resp-party.xsl" />
	<xsl:include href="ref-system.xsl" />
	<xsl:include href="identification.xsl" />

	<!--
		=============================================================================
	-->

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />

	<!--
		=============================================================================
	-->

	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>

	<!--
		=============================================================================
	-->
	<xsl:template
		match="WMT_MS_Capabilities[//Layer/Name=$Name]|wms:WMS_Capabilities[//wms:Layer/wms:Name=$Name]|wfs:WFS_Capabilities[//wfs:FeatureType/wfs:Name=$Name]|wcs:WCS_Capabilities[//wcs:CoverageOfferingBrief/wcs:name=$Name]">

		<xsl:variable name="ows">
			<xsl:choose>
				<xsl:when test="local-name(.)='WFS_Capabilities' and namespace-uri(.)='http://www.opengis.net/wfs' and @version='1.1.0'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="layermatch" select="$layermap/layers/layer/name[normalize-space()=$Name]"/>

		<xsl:variable name="metadatasubtemplateurl" select="$layermap/layers/@metadatasubtemplateurl"/>

		<xsl:variable name="parentuuid" select="$layermap/layers/layer[normalize-space(name)=$Name]/parent"/>
		<xsl:variable name="parentmatch" select="$layermap/layers/parents/parent[@uuid=$parentuuid]"/>

		<xsl:if test="normalize-space($layermatch)!=''">

		<xsl:message>LAYER FOUND:<xsl:value-of select="$Name"/></xsl:message>

		<mcp:MD_Metadata gco:isoType="gmd:MD_Metadata">

			<!--
				- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			-->

			<fileIdentifier>
				<gco:CharacterString>
					<xsl:value-of select="$uuid" />
				</gco:CharacterString>
			</fileIdentifier>

			<!--
				- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			-->

			<language>
				<gco:CharacterString>
					<xsl:value-of select="$lang" />
				</gco:CharacterString>
			</language>

			<!--
				- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			-->

			<characterSet>
				<MD_CharacterSetCode codeList="./resources/codeList.xml#MD_CharacterSetCode"
					codeListValue="utf8" />
			</characterSet>

			<!-- parentIdentifier -->
			<!-- mdHrLv -->
			<hierarchyLevel>
				<MD_ScopeCode codeList="./resources/codeList.xml#MD_ScopeCode"
					codeListValue="dataset" />
			</hierarchyLevel>

			<!-- mdHrLvName -->

			<!--
				- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			-->
			<xsl:variable name="df">[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]</xsl:variable>
			<dateStamp>
				<gco:DateTime><xsl:value-of select="format-dateTime(current-dateTime(),$df)"/></gco:DateTime>
			</dateStamp>

			<!--
				- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			-->
			<metadataStandardName>
				<gco:CharacterString>Australian Marine Community Profile of ISO 19115:2005/19139</gco:CharacterString>
			</metadataStandardName>

			<metadataStandardVersion>
				<gco:CharacterString>1.5-experimental</gco:CharacterString>
			</metadataStandardVersion>

			<!-- spatRepInfo-->
			<xsl:choose>
				<!-- WMS 1.1.0 is space separated -->
				<xsl:when test="@version='1.1.0' or @version='1.0.0'">
					<xsl:for-each select="tokenize(//Layer[Name=$Name]/SRS, ' ') ">
						<referenceSystemInfo>
							<MD_ReferenceSystem>
								<xsl:call-template name="RefSystemTypes">
									<xsl:with-param name="srs" select="."/>
								</xsl:call-template>
							</MD_ReferenceSystem>
						</referenceSystemInfo>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="//wms:Layer[wms:Name=$Name]/wms:CRS[position() &lt; $maxCRS]|//Layer[Name=$Name]/SRS[position() &lt; $maxCRS]">
						<referenceSystemInfo>
							<MD_ReferenceSystem>
								<xsl:call-template name="RefSystemTypes">
									<xsl:with-param name="srs" select="."/>
								</xsl:call-template>
							</MD_ReferenceSystem>
						</referenceSystemInfo>
					</xsl:for-each>			
				</xsl:otherwise>
			</xsl:choose>
			
			<!--mdExtInfo-->
			<!--
				- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			-->
			<identificationInfo>
				<mcp:MD_DataIdentification gco:isoType="gmd:MD_DataIdentification">
					<xsl:apply-templates select="." mode="LayerDataIdentification">
						<xsl:with-param name="Name" select="$Name" />
						<xsl:with-param name="topic" select="$topic" />
						<xsl:with-param name="ows" select="$ows" />
						<xsl:with-param name="parentmatch" select="$parentmatch" />
						<xsl:with-param name="metadatasubtemplateurl" select="$metadatasubtemplateurl" />
					</xsl:apply-templates>
				</mcp:MD_DataIdentification>
			</identificationInfo>

			<!--contInfo-->
			<!--distInfo -->
			<distributionInfo>
				<MD_Distribution>
					<distributionFormat>
						<MD_Format>
							<name gco:nilReason="missing">
								<gco:CharacterString />
							</name>
							<version gco:nilReason="missing">
								<gco:CharacterString />
							</version>
						</MD_Format>
					</distributionFormat>
					<transferOptions>
						<MD_DigitalTransferOptions>
							<onLine>
								<CI_OnlineResource>
									<linkage>
										<URL>
											<xsl:choose>
												<xsl:when test="normalize-space($layermatch)">
													<xsl:value-of select="$layermap/layers/@url"/>
												</xsl:when>
												<xsl:when test="$ows='true'">
													<xsl:value-of
														select="//ows:Operation[@name='GetFeature']/ows:DCP/ows:HTTP/ows:Get/@xlink:href" />
												</xsl:when>
												<xsl:when test="name(.)='WFS_Capabilities'">
													<xsl:value-of
														select="//wfs:GetFeature/wfs:DCPType/wfs:HTTP/wfs:Get/@onlineResource" />
												</xsl:when>
												<xsl:when test="name(.)='WMT_MS_Capabilities'">
													<xsl:value-of
														select="//GetMap/DCPType/HTTP/Get/OnlineResource/@xlink:href" />
												</xsl:when>
                                                <xsl:when test="name(.)='WMS_Capabilities'">
													<xsl:value-of
														select="//wms:GetMap/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of
														select="//wcs:GetCoverage/wcs:DCPType/wcs:HTTP/wcs:Get/wcs:OnlineResource/@xlink:href" />
												</xsl:otherwise>
											</xsl:choose>
										</URL>
									</linkage>
									<protocol>
										<xsl:choose>
											<xsl:when test="name(.)='WMT_MS_Capabilities'">
												<gco:CharacterString>OGC:WMS-1.1.1-http-get-map
												</gco:CharacterString>
											</xsl:when>
                                            <xsl:when test="name(.)='WMS_Capabilities'">
												<gco:CharacterString>OGC:WMS-1.3.0-http-get-map
												</gco:CharacterString>
											</xsl:when>
											<xsl:when test="$ows='true'">
												<gco:CharacterString>OGC:WFS-1.1.0-http-get-feature
												</gco:CharacterString>
											</xsl:when>
											<xsl:when test="name(.)='WFS_Capabilities'">
												<gco:CharacterString>OGC:WFS-1.0.0-http-get-feature
												</gco:CharacterString>
											</xsl:when>
											<xsl:otherwise>
												<gco:CharacterString>OGC:WCS-1.0.0-http-get-coverage
												</gco:CharacterString>
											</xsl:otherwise>
										</xsl:choose>
									</protocol>
									<name>
										<gco:CharacterString>
											<xsl:value-of select="$Name" />
										</gco:CharacterString>
									</name>
									<description>
										<gco:CharacterString>
											<xsl:choose>
												<xsl:when test="name(.)='WFS_Capabilities' or $ows='true'">
													<xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:Title" />
												</xsl:when>
												<xsl:when test="name(.)='WMT_MS_Capabilities'">
													<xsl:value-of select="//Layer[Name=$Name]/Title" />
												</xsl:when>
                                                <xsl:when test="name(.)='WMS_Capabilities'">
													<xsl:value-of select="//wms:Layer[wms:Name=$Name]/wms:Title" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of
														select="//wcs:CoverageOfferingBrief[wcs:name=$Name]/wcs:description" />
												</xsl:otherwise>
											</xsl:choose>
										</gco:CharacterString>
									</description>
								</CI_OnlineResource>
							</onLine>
							<xsl:apply-templates mode="onlineResource"/>
							<xsl:if test="$parentmatch/@data!='' and (//wms:Layer[wms:Name=$Name]/wms:Title or //Layer[Name=$Name]/Title)">
								<xsl:variable name="datatitle" select="//wms:Layer[wms:Name=$Name]/wms:Title|//Layer[Name=$Name]/Title"/>
								<xsl:variable name="dataurl" select="$parentmatch/@data"/>
								<xsl:variable name="suffix" select="$parentmatch/@datasuffix"/>
								<xsl:call-template name="onlineResource">
									<xsl:with-param name="name" select="$datatitle"/>
									<xsl:with-param name="url" select="concat($dataurl,$datatitle,$suffix)"/>
									<xsl:with-param name="protocol" select="'WWW:LINK-1.0-http--link'"/>
								</xsl:call-template>
							</xsl:if>
						</MD_DigitalTransferOptions>
					</transferOptions>
				</MD_Distribution>
			</distributionInfo>

			<!--dqInfo-->
			
		<xsl:variable name="dataQualityInfo" as="node()">
			<xsl:call-template name="addXlink">
				<xsl:with-param name="element" select="'gmd:dataQualityInfo'"/>
				<xsl:with-param name="parentmatch" select="$parentmatch"/>
				<xsl:with-param name="metadatasubtemplateurl" select="$metadatasubtemplateurl"/>
			</xsl:call-template>
		</xsl:variable>


		<xsl:choose>
			<xsl:when test="count($dataQualityInfo/*)>0">

			<xsl:copy-of select="$dataQualityInfo/*"/>

			</xsl:when>
			<xsl:otherwise>

			<dataQualityInfo>
				<DQ_DataQuality>
					<scope>
						<DQ_Scope>
							<level>
								<MD_ScopeCode codeListValue="dataset"
									codeList="./resources/codeList.xml#MD_ScopeCode" />
							</level>
						</DQ_Scope>
					</scope>
					<lineage>
						<LI_Lineage>
							<statement gco:nilReason="missing">
								<gco:CharacterString />
							</statement>
						</LI_Lineage>
					</lineage>
				</DQ_DataQuality>
			</dataQualityInfo>

			</xsl:otherwise>
		</xsl:choose>
			<!--mdConst -->
			<!--mdMaint-->

		<xsl:variable name="metadataContactInfo" as="node()">
			<xsl:call-template name="addXlink">
				<xsl:with-param name="element" select="'mcp:metadataContactInfo'"/>
				<xsl:with-param name="parentmatch" select="$parentmatch"/>
				<xsl:with-param name="metadatasubtemplateurl" select="$metadatasubtemplateurl"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="count($metadataContactInfo/*)>0">
			<xsl:copy-of select="$metadataContactInfo/*"/>
		</xsl:if>


		</mcp:MD_Metadata>

		</xsl:if>
	</xsl:template>

	<!-- Create as many online resource as result format available in WFS server
		to download features using GetFeature operation.
		
		WFS 1.1.0
	-->
	<xsl:template mode="onlineResource" match="//ows:Operation[@name='GetFeature']/ows:Parameter[@name='outputFormat']/ows:Value" priority="2">
		<xsl:variable name="format" select="."/>
		<xsl:variable name="baseUrl"
			select="//ows:Operation[@name='GetFeature']/ows:DCP/ows:HTTP/ows:Get/@xlink:href" />
		
		<xsl:variable name="url">
			<xsl:value-of select="$baseUrl"/>
			<xsl:if test="not(contains($baseUrl, '?'))">?</xsl:if>
			<xsl:text>&amp;request=GetFeature&amp;service=WFS&amp;typename=</xsl:text>
			<xsl:value-of select="$Name" />
			<xsl:text>&amp;outputFormat=</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>&amp;version=1.1.0</xsl:text>
		</xsl:variable>
		
		<xsl:call-template name="onlineResource">
			<xsl:with-param name="name" select="$Name"/>
			<xsl:with-param name="url" select="$url"/>
			<xsl:with-param name="title">
				<xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:Title" />
				(<xsl:value-of select="."/>)
			</xsl:with-param>
			<xsl:with-param name="protocol" select="'OGC:WFS-1.1.0-http-get-feature'"/>
		</xsl:call-template>
		
	</xsl:template>


	<!--
		WFS 1.0.0
	-->
	<xsl:template mode="onlineResource" match="//wfs:GetFeature/wfs:ResultFormat/*" priority="2">
		<xsl:variable name="format" select="name(.)"/>
		
		<xsl:variable name="baseUrl"
			select="../../wfs:DCPType/wfs:HTTP/wfs:Get/@onlineResource" />
		
		<xsl:variable name="url">
			<xsl:value-of select="$baseUrl"/>
			<xsl:if test="not(contains($baseUrl, '?'))">?</xsl:if>
			<xsl:text>&amp;request=GetFeature&amp;service=WFS&amp;typename=</xsl:text>
			<xsl:value-of select="$Name" />
			<xsl:text>&amp;outputFormat=</xsl:text>
			<xsl:value-of select="$format"/>
			<xsl:text>&amp;version=1.0.0</xsl:text>
		</xsl:variable>
		
		<xsl:call-template name="onlineResource">
			<xsl:with-param name="name" select="$Name"/>
			<xsl:with-param name="url" select="$url"/>
			<xsl:with-param name="title">
				<xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:Title" />
				(<xsl:value-of select="name(.)"/>)
			</xsl:with-param>
			<xsl:with-param name="protocol" select="'OGC:WFS-1.0.0-http-get-feature'"/>
		</xsl:call-template>
	</xsl:template>


	<!-- Metadata URL 
	-->
	<xsl:template mode="onlineResource" match="
		//wms:Layer[wms:Name=$Name]/wms:MetadataURL|
		//Layer[Name=$Name]/MetadataURL" priority="2">
	
		<xsl:variable name="layermatch" select="$layermap/layers/layer[normalize-space()=$Name]"/>
		<xsl:if test="$layermatch">
			<xsl:message>LAYER WITH METADATAURL <xsl:value-of select="$Name"/></xsl:message>
			<xsl:call-template name="onlineResource">
				<xsl:with-param name="name" select="concat($Name, ' (', name(.) ,')')"/>
				<xsl:with-param name="url" select="wms:OnlineResource/@xlink:href|OnlineResource/@xlink:href"/>
				<xsl:with-param name="protocol" select="wms:Format|Format"/>
			</xsl:call-template>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template mode="onlineResource" match="
		//wms:Layer[wms:Name=$Name]/wms:Style/wms:LegendURL|
		//Layer[Name=$Name]/Style/LegendURL" priority="2">
		
			<xsl:call-template name="onlineResource">
				<xsl:with-param name="name" select="concat(../Title|../wms:Title, ' (', name(.) ,')')"/>
				<xsl:with-param name="url" select="wms:OnlineResource/@xlink:href|OnlineResource/@xlink:href"/>
				<xsl:with-param name="protocol" select="wms:Format|Format"/>
			</xsl:call-template>
		
	</xsl:template>
	
	<xsl:template mode="onlineResource" match="*">
		<xsl:apply-templates mode="onlineResource" select="*"/>
	</xsl:template>
	
	<xsl:template name="onlineResource">
		<xsl:param name="name"/>
		<xsl:param name="url"/>
		<xsl:param name="title"/>
		<xsl:param name="protocol"/>
		
		<onLine>
			<CI_OnlineResource>
				<linkage>
					<URL>
						<xsl:value-of select="$url"/>
					</URL>
				</linkage>
				<protocol>
					<gco:CharacterString>
						<xsl:value-of select="$protocol"/>
					</gco:CharacterString>
				</protocol>
				<name>
					<gco:CharacterString>
						<xsl:value-of select="$name" />
					</gco:CharacterString>
				</name>
				<description>
					<gco:CharacterString>
						<xsl:value-of select="$title"/>
					</gco:CharacterString>
				</description>
			</CI_OnlineResource>
		</onLine>
	</xsl:template>

	<!--
		=============================================================================
	-->

</xsl:stylesheet>
