<?xml version='1.0' encoding='UTF-8'?>
<hudson>
  <disabledAdministrativeMonitors/>
  <version>1.625.3</version>
  <numExecutors>5</numExecutors>
  <mode>NORMAL</mode>
  <useSecurity>true</useSecurity>
  <authorizationStrategy class="org.jenkinsci.plugins.GithubAuthorizationStrategy" plugin="github-oauth@0.22.2">
    <rootACL>
      <organizationNameList class="linked-list">
        <string></string>
      </organizationNameList>
      <adminUserNameList class="linked-list">
        <string>countspongebob</string>
        <string>l337ch</string>
        <string>maratoid</string>
        <string>mikeln</string>
        <string>richardkaufmann</string>
        <string>Rick-Lindberg</string>
        <string>SamsungAGJenkinsBot</string>
        <string>spiffxp</string>
      </adminUserNameList>
      <authenticatedUserReadPermission>false</authenticatedUserReadPermission>
      <useRepositoryPermissions>true</useRepositoryPermissions>
      <authenticatedUserCreateJobPermission>false</authenticatedUserCreateJobPermission>
      <allowGithubWebHookPermission>true</allowGithubWebHookPermission>
      <allowCcTrayPermission>false</allowCcTrayPermission>
      <allowAnonymousReadPermission>false</allowAnonymousReadPermission>
    </rootACL>
  </authorizationStrategy>
  <securityRealm class="org.jenkinsci.plugins.GithubSecurityRealm">
    <githubWebUri>https://github.com</githubWebUri>
    <githubApiUri>https://api.github.com</githubApiUri>
    <clientID>${github_client_id}</clientID>
    <clientSecret>${github_client_key}</clientSecret>
  </securityRealm>
  <disableRememberMe>false</disableRememberMe>
  <projectNamingStrategy class="jenkins.model.ProjectNamingStrategy$DefaultProjectNamingStrategy"/>
  <workspaceDir>$${ITEM_ROOTDIR}/workspace</workspaceDir>
  <buildsDir>$${ITEM_ROOTDIR}/builds</buildsDir>
  <markupFormatter class="hudson.markup.RawHtmlMarkupFormatter" plugin="antisamy-markup-formatter@1.3">
    <disableSyntaxHighlighting>false</disableSyntaxHighlighting>
  </markupFormatter>
  <markupFormatter class="hudson.markup.EscapedMarkupFormatter"/>
  <jdks/>
  <viewsTabBar class="hudson.views.DefaultViewsTabBar"/>
  <myViewsTabBar class="hudson.views.DefaultMyViewsTabBar"/>
  <clouds/>
  <slaves/>
  <quietPeriod>5</quietPeriod>
  <scmCheckoutRetryCount>0</scmCheckoutRetryCount>
  <views>
    <hudson.model.AllView>
      <owner class="hudson" reference="../../.."/>
      <name>All</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
    </hudson.model.AllView>
  </views>
  <primaryView>All</primaryView>
  <slaveAgentPort>5000</slaveAgentPort>
  <label></label>
  <nodeProperties/>
  <globalNodeProperties>
    <hudson.slaves.EnvironmentVariablesNodeProperty>
      <envVars serialization="custom">
        <unserializable-parents/>
        <tree-map>
          <default>
            <comparator class="hudson.util.CaseInsensitiveComparator"/>
          </default>
          <int>4</int>
          <!-- used by awscli and other tools that need AWS access -->
          <string>AWS_DEFAULT_REGION</string>
          <string>us-west-2</string>
          <!-- used by jobs that use kraken/bin/kraken-*.sh scripts -->
          <string>KRAKEN_DEFAULT_VPC</string>
          <string>vpc-e9cd4a8c</string>
          <!-- used by jobs that use kraken/bin/kraken-*.sh scripts -->
          <string>KRAKEN_USER_PREFIX</string>
          <string>pipelet</string>
          <!-- used by jobs that use kraken/bin/kraken-*.sh scripts -->
          <string>PIPELET_DOCKERMACHINE</string>
          <string>pipelet-dockermachine</string>
        </tree-map>
      </envVars>
    </hudson.slaves.EnvironmentVariablesNodeProperty>
  </globalNodeProperties>
</hudson>
