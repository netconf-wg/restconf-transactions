<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xi="http://www.w3.org/2001/XInclude"
		version="1.0">

  <xsl:param name="i-d-name">draft-FOO</xsl:param>
  <xsl:param name="i-d-rev">XX</xsl:param>
  <xsl:param name="date">YYYY-MM-DD</xsl:param>
  <xsl:variable name="mm-dd" select="substring-after($date,'-')"/>
  <xsl:variable name="month">
    <xsl:variable name="mm" select="substring-before($mm-dd,'-')"/>
    <xsl:choose>
      <xsl:when test="$mm = 1">January</xsl:when>
      <xsl:when test="$mm = 2">February</xsl:when>
      <xsl:when test="$mm = 3">March</xsl:when>
      <xsl:when test="$mm = 4">April</xsl:when>
      <xsl:when test="$mm = 5">May</xsl:when>
      <xsl:when test="$mm = 6">June</xsl:when>
      <xsl:when test="$mm = 7">July</xsl:when>
      <xsl:when test="$mm = 8">August</xsl:when>
      <xsl:when test="$mm = 9">September</xsl:when>
      <xsl:when test="$mm = 10">October</xsl:when>
      <xsl:when test="$mm = 11">November</xsl:when>
      <xsl:when test="$mm = 12">December</xsl:when>
      <xsl:otherwise>***set date***</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable
      name="bibxml">http://xml2rfc.ietf.org/public/rfc/bibxml</xsl:variable>
  <xsl:variable
      name="std-refs"
      select="//xref[starts-with(@target, 'RFC') or
	      starts-with(@target, 'I-D.') or
	      starts-with(@target, 'W3C.')]"/>

  <xsl:template name="process-all-children">
    <xsl:apply-templates
	select="*|@*|text()|comment()|processing-instruction()"/>
  </xsl:template>

  <xsl:template name="add-include">
    <xsl:param name="tail"/>
  </xsl:template>

  <xsl:template name="ref-includes">
    <xsl:for-each select="$std-refs">
      <xsl:variable name="url">
	<xsl:value-of select="$bibxml"/>
	<xsl:choose>
	  <xsl:when test="starts-with(@target, 'RFC')">
	    <xsl:value-of select="concat('/reference.RFC.',
				  substring-after(@target, 'RFC'))"/>
	  </xsl:when>
	  <xsl:when test="starts-with(@target, 'I-D.')">
	    <xsl:value-of select="concat('3/reference.I-D.',
				  substring-after(@target, 'I-D.'))"/>
	  </xsl:when>
	  <xsl:when test="starts-with(@target, 'W3C.')">
	    <xsl:value-of select="concat('4/reference.W3C.',
				  substring-after(@target, 'W3C.'))"/>
	  </xsl:when>
	</xsl:choose>
	<xsl:text>.xml</xsl:text>
      </xsl:variable>
      <xsl:if test="not(/rfc/back/references[xi:include/@href=$url
		    or reference/@anchor=current()/@target])">
	<xsl:element name="xi:include">
	  <xsl:attribute name="href">
	    <xsl:value-of select="$url"/>
	  </xsl:attribute>
	</xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="add-refs">
    <xsl:if test="$std-refs">
      <xsl:element name="references">
	<xsl:attribute name="title">Normative References</xsl:attribute>
	<xsl:call-template name="ref-includes"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*|@*|text()|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:call-template name="process-all-children"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/rfc">
    <xsl:copy>
      <xsl:if test="not(@docName)">
	<xsl:attribute name="docName">
	  <xsl:value-of select="concat($i-d-name,'-',$i-d-rev)"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="not(@ipr)">
	<xsl:attribute name="ipr">trust200902</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="process-all-children"/>
      <xsl:if test="not(back)">
	<xsl:element name="back">
	  <xsl:call-template name="add-refs"/>
	</xsl:element>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/rfc/@docName">
    <xsl:attribute name="docName">
      <xsl:value-of select="concat(.,'-',$i-d-rev)"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="/rfc/front/date">
    <xsl:element name="date">
      <xsl:attribute name="day">
	<xsl:value-of select="substring-after($mm-dd,'-')"/>
      </xsl:attribute>
      <xsl:attribute name="month">
	<xsl:value-of select="$month"/>
      </xsl:attribute>
      <xsl:attribute name="year">
	<xsl:value-of select="substring-before($date,'-')"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="/rfc/back[not(references)]">
    <xsl:copy>
      <xsl:call-template name="add-refs"/>
      <xsl:call-template name="process-all-children"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/rfc/back/references[position()=1]">
    <xsl:copy>
      <xsl:call-template name="process-all-children"/>
      <xsl:call-template name="ref-includes"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
