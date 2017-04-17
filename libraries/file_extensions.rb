require 'rexml/document'
include REXML


module IIS
  module RequestFiltering
    module FileExtensions

      ######################################################################################################
      ## Class to define an allowed/excluded fileExtension.
      ######################################################################################################
      class FileExtensionEntry

        @fileExtension
        @allowed

        def initialize(fileExtension, allowed)
          @fileExtension = fileExtension
          @allowed = allowed
        end

        def equals?(requestFilter)
          if (@fileExtension.downcase == requestFilter.fileExtension.downcase &&
              @allowed.to_s.downcase == requestFilter.allowed.to_s.downcase)
            return true
          end

          return false
        end

        def fileExtension
          @fileExtension
        end

        def allowed
          @allowed
        end
      end

      ######################################################################################################
      ## Class to load and hold all extensions in the IIS fileExtension section in RequestFiltering.
      ## This is based off of IIS_schema.xml found at: %windir%\system32\inetsrv\config\schema\IIS_Schema.xml
      ##
      ## <element name="fileExtensions">
      ##  <attribute name="allowUnlisted" type="bool" defaultValue="true" />
      ##  <attribute name="applyToWebDAV" type="bool" defaultValue="true" />
      ##  <collection addElement="add" clearElement="clear" removeElement="remove" >
      ##    <attribute name="fileExtension" type="string" required="true" isUniqueKey="true" validationType="nonEmptyString" />
      ##    <attribute name="allowed" type="bool" required="true" defaultValue="true" />
      ##  </collection>
      ## </element>
      ######################################################################################################
      class FileExtensionContainer

        @xml
        @items

        def initialize(xmlDocument)
          @xml = xmlDocument
          @items = {}
          load_xml()
        end

        def has_item(item)
          if (@items[item.fileExtension])
            return item.equals?(@items[item.fileExtension])
          end

          return false
        end

        def get_file_extension(fileExtension)
          if (@items == nil || fileExtension == nil)
            return nil
          end

          return @items[fileExtension.downcase]
        end

        def load_xml
          ## load the xml into RequestFilter objects
          XPath.each(@xml.root, "CONFIG/system.webServer-security-requestFiltering/fileExtensions/add") do |element|
            ## Now that we have each element, create an object
            fileExtension = element.attributes["fileExtension"].downcase
            allowed = element.attributes["allowed"].downcase
            #Chef::Log.info("-- request_filtering.rb: element - #{element}")
            @items[fileExtension] = FileExtensionEntry.new(fileExtension, allowed)
          end
        end
      end

      ######################################################################################################
      ## Class meant to build commands to be run with IIS appcmd.  This class is only responsible for
      ## building the command, not executing it.
      ######################################################################################################
      class FileExtensionAppCommandBuilder
        @fileExtensionContainer
        @baseAppCmdString
        @allowedExtensions
        @excludedExtensions

        def initialize(fileExtensionContainer, baseAppCmdString, allowedExtensions, excludedExtensions)
          @fileExtensionContainer = fileExtensionContainer
          @baseAppCmdString = baseAppCmdString
          @allowedExtensions = allowedExtensions
          @excludedExtensions = excludedExtensions
        end

        def build_command()
          was_updated = false
          cmd = "#{@baseAppCmdString} set config -section:system.webServer/security/requestFiltering"
          @allowedExtensions.each do |extension|
            file_extension_cmd = build_file_extension_command(extension, true)
            if (file_extension_cmd != '')
              was_updated = true
              cmd << file_extension_cmd
            end
          end

          @excludedExtensions.each do |extension|
            file_extension_cmd = build_file_extension_command(extension, false)
            if (file_extension_cmd != '')
              was_updated = true
              cmd << file_extension_cmd
            end

          end
          Chef::Log.info("exiting build_file_extension_command - #{cmd}")

          return (was_updated) ? cmd : nil
        end

        private

        ## Need to build the command
        def build_file_extension_command(extension, shouldAllow)
          cmd = ''

          fileExtension = @fileExtensionContainer.get_file_extension(extension)
          if (fileExtension != nil)
            #Chef::Log.info("fileExtension: #{fileExtension.fileExtension} #{fileExtension.allowed.to_s == shouldAllow.to_s} ")
            if (fileExtension.allowed.to_s != shouldAllow.to_s)
              cmd << " /-fileExtensions.[fileExtension='#{extension}']"
              cmd << " /+fileExtensions.[fileExtension='#{extension}',allowed='#{shouldAllow}']"
            end
          else
            cmd << " /+fileExtensions.[fileExtension='#{extension}',allowed='#{shouldAllow}']"
          end

          return cmd
        end
      end
    end
  end
end
