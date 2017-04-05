#
# Cookbook:: iis
# Library:: helper
#
# Copyright:: 2013-2017, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Opscode
  module IIS
    # Contains functions that are used throughout this cookbook
    module Helper
      @iis_version = nil

      if RUBY_PLATFORM =~ /mswin|mingw32|windows/
        require 'chef/win32/version'
        require 'win32/registry'
      end

      require 'rexml/document'
      require 'chef/mixin/shell_out'

      include Chef::Mixin::ShellOut
      include REXML
      include Windows::Helper

      def self.older_than_windows2008r2?
        if RUBY_PLATFORM =~ /mswin|mingw32|windows/
          win_version = Chef::ReservedNames::Win32::Version.new
          win_version.windows_server_2008? ||
            win_version.windows_vista? ||
            win_version.windows_server_2003_r2? ||
            win_version.windows_home_server? ||
            win_version.windows_server_2003? ||
            win_version.windows_xp? ||
            win_version.windows_2000?
        end
      end

      def self.older_than_windows2012?
        if RUBY_PLATFORM =~ /mswin|mingw32|windows/
          win_version = Chef::ReservedNames::Win32::Version.new
          win_version.windows_7? ||
            win_version.windows_server_2008_r2? ||
            win_version.windows_server_2008? ||
            win_version.windows_vista? ||
            win_version.windows_server_2003_r2? ||
            win_version.windows_home_server? ||
            win_version.windows_server_2003? ||
            win_version.windows_xp? ||
            win_version.windows_2000?
        end
      end

      def self.windows_cleanpath(path)
        path = if defined?(Chef::Util::PathHelper.cleanpath).nil?
                 win_friendly_path(path)
               else
                 Chef::Util::PathHelper.cleanpath(path)
               end
        # Remove any trailing slashes to prevent them from accidentally escaping any quotes.
        path.chomp('/').chomp('\\')
      end

      def self.value(document, xpath)
        XPath.first(document, xpath).to_s
      end

      def self.new_value?(document, xpath, value_to_check)
        XPath.first(document, xpath).to_s != value_to_check.to_s
      end

      def self.new_or_empty_value?(document, xpath, value_to_check)
        value_to_check.to_s != '' && new_value?(document, xpath, value_to_check)
      end

      def self.appcmd(node)
        @appcmd ||= begin
          "#{node['iis']['home']}\\appcmd.exe"
        end
      end

      def self.iis_version
        if @iis_version.nil?
          version_string = Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Microsoft\InetStp').read('VersionString')[1]
          version_string.slice! 'Version '
          @iis_version = version_string
        end
        @iis_version.to_f
      end

      def self.default_mime_types
        [
          "fileExtension='.323',mimeType='text/h323'",
          "fileExtension='.3g2',mimeType='video/3gpp2'",
          "fileExtension='.3gp2',mimeType='video/3gpp2'",
          "fileExtension='.3gp',mimeType='video/3gpp'",
          "fileExtension='.3gpp',mimeType='video/3gpp'",
          "fileExtension='.aaf',mimeType='application/octet-stream'",
          "fileExtension='.aac',mimeType='audio/aac'",
          "fileExtension='.aca',mimeType='application/octet-stream'",
          "fileExtension='.accdb',mimeType='application/msaccess'",
          "fileExtension='.accde',mimeType='application/msaccess'",
          "fileExtension='.accdt',mimeType='application/msaccess'",
          "fileExtension='.acx',mimeType='application/internet-property-stream'",
          "fileExtension='.adt',mimeType='audio/vnd.dlna.adts'",
          "fileExtension='.adts',mimeType='audio/vnd.dlna.adts'",
          "fileExtension='.afm',mimeType='application/octet-stream'",
          "fileExtension='.ai',mimeType='application/postscript'",
          "fileExtension='.aif',mimeType='audio/x-aiff'",
          "fileExtension='.aifc',mimeType='audio/aiff'",
          "fileExtension='.aiff',mimeType='audio/aiff'",
          "fileExtension='.application',mimeType='application/x-ms-application'",
          "fileExtension='.art',mimeType='image/x-jg'",
          "fileExtension='.asd',mimeType='application/octet-stream'",
          "fileExtension='.asf',mimeType='video/x-ms-asf'",
          "fileExtension='.asi',mimeType='application/octet-stream'",
          "fileExtension='.asm',mimeType='text/plain'",
          "fileExtension='.asr',mimeType='video/x-ms-asf'",
          "fileExtension='.asx',mimeType='video/x-ms-asf'",
          "fileExtension='.atom',mimeType='application/atom+xml'",
          "fileExtension='.au',mimeType='audio/basic'",
          "fileExtension='.avi',mimeType='video/avi'",
          "fileExtension='.axs',mimeType='application/olescript'",
          "fileExtension='.bas',mimeType='text/plain'",
          "fileExtension='.bcpio',mimeType='application/x-bcpio'",
          "fileExtension='.bin',mimeType='application/octet-stream'",
          "fileExtension='.bmp',mimeType='image/bmp'",
          "fileExtension='.c',mimeType='text/plain'",
          "fileExtension='.cab',mimeType='application/vnd.ms-cab-compressed'",
          "fileExtension='.calx',mimeType='application/vnd.ms-office.calx'",
          "fileExtension='.cat',mimeType='application/vnd.ms-pki.seccat'",
          "fileExtension='.cdf',mimeType='application/x-cdf'",
          "fileExtension='.chm',mimeType='application/octet-stream'",
          "fileExtension='.class',mimeType='application/x-java-applet'",
          "fileExtension='.clp',mimeType='application/x-msclip'",
          "fileExtension='.cmx',mimeType='image/x-cmx'",
          "fileExtension='.cnf',mimeType='text/plain'",
          "fileExtension='.cod',mimeType='image/cis-cod'",
          "fileExtension='.cpio',mimeType='application/x-cpio'",
          "fileExtension='.cpp',mimeType='text/plain'",
          "fileExtension='.crd',mimeType='application/x-mscardfile'",
          "fileExtension='.crl',mimeType='application/pkix-crl'",
          "fileExtension='.crt',mimeType='application/x-x509-ca-cert'",
          "fileExtension='.csh',mimeType='application/x-csh'",
          "fileExtension='.css',mimeType='text/css'",
          "fileExtension='.csv',mimeType='application/octet-stream'",
          "fileExtension='.cur',mimeType='application/octet-stream'",
          "fileExtension='.dcr',mimeType='application/x-director'",
          "fileExtension='.deploy',mimeType='application/octet-stream'",
          "fileExtension='.der',mimeType='application/x-x509-ca-cert'",
          "fileExtension='.dib',mimeType='image/bmp'",
          "fileExtension='.dir',mimeType='application/x-director'",
          "fileExtension='.disco',mimeType='text/xml'",
          "fileExtension='.dll',mimeType='application/x-msdownload'",
          "fileExtension='.dll.config',mimeType='text/xml'",
          "fileExtension='.dlm',mimeType='text/dlm'",
          "fileExtension='.doc',mimeType='application/msword'",
          "fileExtension='.docm',mimeType='application/vnd.ms-word.document.macroEnabled.12'",
          "fileExtension='.docx',mimeType='application/vnd.openxmlformats-officedocument.wordprocessingml.document'",
          "fileExtension='.dot',mimeType='application/msword'",
          "fileExtension='.dotm',mimeType='application/vnd.ms-word.template.macroEnabled.12'",
          "fileExtension='.dotx',mimeType='application/vnd.openxmlformats-officedocument.wordprocessingml.template'",
          "fileExtension='.dsp',mimeType='application/octet-stream'",
          "fileExtension='.dtd',mimeType='text/xml'",
          "fileExtension='.dvi',mimeType='application/x-dvi'",
          "fileExtension='.dvr-ms',mimeType='video/x-ms-dvr'",
          "fileExtension='.dwf',mimeType='drawing/x-dwf'",
          "fileExtension='.dwp',mimeType='application/octet-stream'",
          "fileExtension='.dxr',mimeType='application/x-director'",
          "fileExtension='.eml',mimeType='message/rfc822'",
          "fileExtension='.emz',mimeType='application/octet-stream'",
          "fileExtension='.eot',mimeType='application/vnd.ms-fontobject'",
          "fileExtension='.eps',mimeType='application/postscript'",
          "fileExtension='.etx',mimeType='text/x-setext'",
          "fileExtension='.evy',mimeType='application/envoy'",
          "fileExtension='.exe',mimeType='application/octet-stream'",
          "fileExtension='.exe.config',mimeType='text/xml'",
          "fileExtension='.fdf',mimeType='application/vnd.fdf'",
          "fileExtension='.fif',mimeType='application/fractals'",
          "fileExtension='.fla',mimeType='application/octet-stream'",
          "fileExtension='.flr',mimeType='x-world/x-vrml'",
          "fileExtension='.flv',mimeType='video/x-flv'",
          "fileExtension='.gif',mimeType='image/gif'",
          "fileExtension='.gtar',mimeType='application/x-gtar'",
          "fileExtension='.gz',mimeType='application/x-gzip'",
          "fileExtension='.h',mimeType='text/plain'",
          "fileExtension='.hdf',mimeType='application/x-hdf'",
          "fileExtension='.hdml',mimeType='text/x-hdml'",
          "fileExtension='.hhc',mimeType='application/x-oleobject'",
          "fileExtension='.hhk',mimeType='application/octet-stream'",
          "fileExtension='.hhp',mimeType='application/octet-stream'",
          "fileExtension='.hlp',mimeType='application/winhlp'",
          "fileExtension='.hqx',mimeType='application/mac-binhex40'",
          "fileExtension='.hta',mimeType='application/hta'",
          "fileExtension='.htc',mimeType='text/x-component'",
          "fileExtension='.htm',mimeType='text/html'",
          "fileExtension='.html',mimeType='text/html'",
          "fileExtension='.htt',mimeType='text/webviewhtml'",
          "fileExtension='.hxt',mimeType='text/html'",
          "fileExtension='.ico',mimeType='image/x-icon'",
          "fileExtension='.ics',mimeType='text/calendar'",
          "fileExtension='.ief',mimeType='image/ief'",
          "fileExtension='.iii',mimeType='application/x-iphone'",
          "fileExtension='.inf',mimeType='application/octet-stream'",
          "fileExtension='.ins',mimeType='application/x-internet-signup'",
          "fileExtension='.isp',mimeType='application/x-internet-signup'",
          "fileExtension='.IVF',mimeType='video/x-ivf'",
          "fileExtension='.jar',mimeType='application/java-archive'",
          "fileExtension='.java',mimeType='application/octet-stream'",
          "fileExtension='.jck',mimeType='application/liquidmotion'",
          "fileExtension='.jcz',mimeType='application/liquidmotion'",
          "fileExtension='.jfif',mimeType='image/pjpeg'",
          "fileExtension='.jpb',mimeType='application/octet-stream'",
          "fileExtension='.jpe',mimeType='image/jpeg'",
          "fileExtension='.jpeg',mimeType='image/jpeg'",
          "fileExtension='.jpg',mimeType='image/jpeg'",
          "fileExtension='.js',mimeType='application/javascript'",
          "fileExtension='.json',mimeType='application/json'",
          "fileExtension='.jsx',mimeType='text/jscript'",
          "fileExtension='.latex',mimeType='application/x-latex'",
          "fileExtension='.lit',mimeType='application/x-ms-reader'",
          "fileExtension='.lpk',mimeType='application/octet-stream'",
          "fileExtension='.lsf',mimeType='video/x-la-asf'",
          "fileExtension='.lsx',mimeType='video/x-la-asf'",
          "fileExtension='.lzh',mimeType='application/octet-stream'",
          "fileExtension='.m13',mimeType='application/x-msmediaview'",
          "fileExtension='.m14',mimeType='application/x-msmediaview'",
          "fileExtension='.m1v',mimeType='video/mpeg'",
          "fileExtension='.m2ts',mimeType='video/vnd.dlna.mpeg-tts'",
          "fileExtension='.m3u',mimeType='audio/x-mpegurl'",
          "fileExtension='.m4a',mimeType='audio/mp4'",
          "fileExtension='.m4v',mimeType='video/mp4'",
          "fileExtension='.man',mimeType='application/x-troff-man'",
          "fileExtension='.manifest',mimeType='application/x-ms-manifest'",
          "fileExtension='.map',mimeType='text/plain'",
          "fileExtension='.mdb',mimeType='application/x-msaccess'",
          "fileExtension='.mdp',mimeType='application/octet-stream'",
          "fileExtension='.me',mimeType='application/x-troff-me'",
          "fileExtension='.mht',mimeType='message/rfc822'",
          "fileExtension='.mhtml',mimeType='message/rfc822'",
          "fileExtension='.mid',mimeType='audio/mid'",
          "fileExtension='.midi',mimeType='audio/mid'",
          "fileExtension='.mix',mimeType='application/octet-stream'",
          "fileExtension='.mmf',mimeType='application/x-smaf'",
          "fileExtension='.mno',mimeType='text/xml'",
          "fileExtension='.mny',mimeType='application/x-msmoney'",
          "fileExtension='.mov',mimeType='video/quicktime'",
          "fileExtension='.movie',mimeType='video/x-sgi-movie'",
          "fileExtension='.mp2',mimeType='video/mpeg'",
          "fileExtension='.mp3',mimeType='audio/mpeg'",
          "fileExtension='.mp4',mimeType='video/mp4'",
          "fileExtension='.mp4v',mimeType='video/mp4'",
          "fileExtension='.mpa',mimeType='video/mpeg'",
          "fileExtension='.mpe',mimeType='video/mpeg'",
          "fileExtension='.mpeg',mimeType='video/mpeg'",
          "fileExtension='.mpg',mimeType='video/mpeg'",
          "fileExtension='.mpp',mimeType='application/vnd.ms-project'",
          "fileExtension='.mpv2',mimeType='video/mpeg'",
          "fileExtension='.ms',mimeType='application/x-troff-ms'",
          "fileExtension='.msi',mimeType='application/octet-stream'",
          "fileExtension='.mso',mimeType='application/octet-stream'",
          "fileExtension='.mvb',mimeType='application/x-msmediaview'",
          "fileExtension='.mvc',mimeType='application/x-miva-compiled'",
          "fileExtension='.nc',mimeType='application/x-netcdf'",
          "fileExtension='.nsc',mimeType='video/x-ms-asf'",
          "fileExtension='.nws',mimeType='message/rfc822'",
          "fileExtension='.ocx',mimeType='application/octet-stream'",
          "fileExtension='.oda',mimeType='application/oda'",
          "fileExtension='.odc',mimeType='text/x-ms-odc'",
          "fileExtension='.ods',mimeType='application/oleobject'",
          "fileExtension='.oga',mimeType='audio/ogg'",
          "fileExtension='.ogg',mimeType='video/ogg'",
          "fileExtension='.ogv',mimeType='video/ogg'",
          "fileExtension='.one',mimeType='application/onenote'",
          "fileExtension='.onea',mimeType='application/onenote'",
          "fileExtension='.onetoc',mimeType='application/onenote'",
          "fileExtension='.onetoc2',mimeType='application/onenote'",
          "fileExtension='.onetmp',mimeType='application/onenote'",
          "fileExtension='.onepkg',mimeType='application/onenote'",
          "fileExtension='.osdx',mimeType='application/opensearchdescription+xml'",
          "fileExtension='.otf',mimeType='font/otf'",
          "fileExtension='.p10',mimeType='application/pkcs10'",
          "fileExtension='.p12',mimeType='application/x-pkcs12'",
          "fileExtension='.p7b',mimeType='application/x-pkcs7-certificates'",
          "fileExtension='.p7c',mimeType='application/pkcs7-mime'",
          "fileExtension='.p7m',mimeType='application/pkcs7-mime'",
          "fileExtension='.p7r',mimeType='application/x-pkcs7-certreqresp'",
          "fileExtension='.p7s',mimeType='application/pkcs7-signature'",
          "fileExtension='.pbm',mimeType='image/x-portable-bitmap'",
          "fileExtension='.pcx',mimeType='application/octet-stream'",
          "fileExtension='.pcz',mimeType='application/octet-stream'",
          "fileExtension='.pdf',mimeType='application/pdf'",
          "fileExtension='.pfb',mimeType='application/octet-stream'",
          "fileExtension='.pfm',mimeType='application/octet-stream'",
          "fileExtension='.pfx',mimeType='application/x-pkcs12'",
          "fileExtension='.pgm',mimeType='image/x-portable-graymap'",
          "fileExtension='.pko',mimeType='application/vnd.ms-pki.pko'",
          "fileExtension='.pma',mimeType='application/x-perfmon'",
          "fileExtension='.pmc',mimeType='application/x-perfmon'",
          "fileExtension='.pml',mimeType='application/x-perfmon'",
          "fileExtension='.pmr',mimeType='application/x-perfmon'",
          "fileExtension='.pmw',mimeType='application/x-perfmon'",
          "fileExtension='.png',mimeType='image/png'",
          "fileExtension='.pnm',mimeType='image/x-portable-anymap'",
          "fileExtension='.pnz',mimeType='image/png'",
          "fileExtension='.pot',mimeType='application/vnd.ms-powerpoint'",
          "fileExtension='.potm',mimeType='application/vnd.ms-powerpoint.template.macroEnabled.12'",
          "fileExtension='.potx',mimeType='application/vnd.openxmlformats-officedocument.presentationml.template'",
          "fileExtension='.ppam',mimeType='application/vnd.ms-powerpoint.addin.macroEnabled.12'",
          "fileExtension='.ppm',mimeType='image/x-portable-pixmap'",
          "fileExtension='.pps',mimeType='application/vnd.ms-powerpoint'",
          "fileExtension='.ppsm',mimeType='application/vnd.ms-powerpoint.slideshow.macroEnabled.12'",
          "fileExtension='.ppsx',mimeType='application/vnd.openxmlformats-officedocument.presentationml.slideshow'",
          "fileExtension='.ppt',mimeType='application/vnd.ms-powerpoint'",
          "fileExtension='.pptm',mimeType='application/vnd.ms-powerpoint.presentation.macroEnabled.12'",
          "fileExtension='.pptx',mimeType='application/vnd.openxmlformats-officedocument.presentationml.presentation'",
          "fileExtension='.prf',mimeType='application/pics-rules'",
          "fileExtension='.prm',mimeType='application/octet-stream'",
          "fileExtension='.prx',mimeType='application/octet-stream'",
          "fileExtension='.ps',mimeType='application/postscript'",
          "fileExtension='.psd',mimeType='application/octet-stream'",
          "fileExtension='.psm',mimeType='application/octet-stream'",
          "fileExtension='.psp',mimeType='application/octet-stream'",
          "fileExtension='.pub',mimeType='application/x-mspublisher'",
          "fileExtension='.qt',mimeType='video/quicktime'",
          "fileExtension='.qtl',mimeType='application/x-quicktimeplayer'",
          "fileExtension='.qxd',mimeType='application/octet-stream'",
          "fileExtension='.ra',mimeType='audio/x-pn-realaudio'",
          "fileExtension='.ram',mimeType='audio/x-pn-realaudio'",
          "fileExtension='.rar',mimeType='application/octet-stream'",
          "fileExtension='.ras',mimeType='image/x-cmu-raster'",
          "fileExtension='.rf',mimeType='image/vnd.rn-realflash'",
          "fileExtension='.rgb',mimeType='image/x-rgb'",
          "fileExtension='.rm',mimeType='application/vnd.rn-realmedia'",
          "fileExtension='.rmi',mimeType='audio/mid'",
          "fileExtension='.roff',mimeType='application/x-troff'",
          "fileExtension='.rpm',mimeType='audio/x-pn-realaudio-plugin'",
          "fileExtension='.rtf',mimeType='application/rtf'",
          "fileExtension='.rtx',mimeType='text/richtext'",
          "fileExtension='.scd',mimeType='application/x-msschedule'",
          "fileExtension='.sct',mimeType='text/scriptlet'",
          "fileExtension='.sea',mimeType='application/octet-stream'",
          "fileExtension='.setpay',mimeType='application/set-payment-initiation'",
          "fileExtension='.setreg',mimeType='application/set-registration-initiation'",
          "fileExtension='.sgml',mimeType='text/sgml'",
          "fileExtension='.sh',mimeType='application/x-sh'",
          "fileExtension='.shar',mimeType='application/x-shar'",
          "fileExtension='.sit',mimeType='application/x-stuffit'",
          "fileExtension='.sldm',mimeType='application/vnd.ms-powerpoint.slide.macroEnabled.12'",
          "fileExtension='.sldx',mimeType='application/vnd.openxmlformats-officedocument.presentationml.slide'",
          "fileExtension='.smd',mimeType='audio/x-smd'",
          "fileExtension='.smi',mimeType='application/octet-stream'",
          "fileExtension='.smx',mimeType='audio/x-smd'",
          "fileExtension='.smz',mimeType='audio/x-smd'",
          "fileExtension='.snd',mimeType='audio/basic'",
          "fileExtension='.snp',mimeType='application/octet-stream'",
          "fileExtension='.spc',mimeType='application/x-pkcs7-certificates'",
          "fileExtension='.spl',mimeType='application/futuresplash'",
          "fileExtension='.spx',mimeType='audio/ogg'",
          "fileExtension='.src',mimeType='application/x-wais-source'",
          "fileExtension='.ssm',mimeType='application/streamingmedia'",
          "fileExtension='.sst',mimeType='application/vnd.ms-pki.certstore'",
          "fileExtension='.stl',mimeType='application/vnd.ms-pki.stl'",
          "fileExtension='.sv4cpio',mimeType='application/x-sv4cpio'",
          "fileExtension='.sv4crc',mimeType='application/x-sv4crc'",
          "fileExtension='.svg',mimeType='image/svg+xml'",
          "fileExtension='.svgz',mimeType='image/svg+xml'",
          "fileExtension='.swf',mimeType='application/x-shockwave-flash'",
          "fileExtension='.t',mimeType='application/x-troff'",
          "fileExtension='.tar',mimeType='application/x-tar'",
          "fileExtension='.tcl',mimeType='application/x-tcl'",
          "fileExtension='.tex',mimeType='application/x-tex'",
          "fileExtension='.texi',mimeType='application/x-texinfo'",
          "fileExtension='.texinfo',mimeType='application/x-texinfo'",
          "fileExtension='.tgz',mimeType='application/x-compressed'",
          "fileExtension='.thmx',mimeType='application/vnd.ms-officetheme'",
          "fileExtension='.thn',mimeType='application/octet-stream'",
          "fileExtension='.tif',mimeType='image/tiff'",
          "fileExtension='.tiff',mimeType='image/tiff'",
          "fileExtension='.toc',mimeType='application/octet-stream'",
          "fileExtension='.tr',mimeType='application/x-troff'",
          "fileExtension='.trm',mimeType='application/x-msterminal'",
          "fileExtension='.ts',mimeType='video/vnd.dlna.mpeg-tts'",
          "fileExtension='.tsv',mimeType='text/tab-separated-values'",
          "fileExtension='.ttf',mimeType='application/octet-stream'",
          "fileExtension='.tts',mimeType='video/vnd.dlna.mpeg-tts'",
          "fileExtension='.txt',mimeType='text/plain'",
          "fileExtension='.u32',mimeType='application/octet-stream'",
          "fileExtension='.uls',mimeType='text/iuls'",
          "fileExtension='.ustar',mimeType='application/x-ustar'",
          "fileExtension='.vbs',mimeType='text/vbscript'",
          "fileExtension='.vcf',mimeType='text/x-vcard'",
          "fileExtension='.vcs',mimeType='text/plain'",
          "fileExtension='.vdx',mimeType='application/vnd.ms-visio.viewer'",
          "fileExtension='.vml',mimeType='text/xml'",
          "fileExtension='.vsd',mimeType='application/vnd.visio'",
          "fileExtension='.vss',mimeType='application/vnd.visio'",
          "fileExtension='.vst',mimeType='application/vnd.visio'",
          "fileExtension='.vsto',mimeType='application/x-ms-vsto'",
          "fileExtension='.vsw',mimeType='application/vnd.visio'",
          "fileExtension='.vsx',mimeType='application/vnd.visio'",
          "fileExtension='.vtx',mimeType='application/vnd.visio'",
          "fileExtension='.wav',mimeType='audio/wav'",
          "fileExtension='.wax',mimeType='audio/x-ms-wax'",
          "fileExtension='.wbmp',mimeType='image/vnd.wap.wbmp'",
          "fileExtension='.wcm',mimeType='application/vnd.ms-works'",
          "fileExtension='.wdb',mimeType='application/vnd.ms-works'",
          "fileExtension='.webm',mimeType='video/webm'",
          "fileExtension='.wks',mimeType='application/vnd.ms-works'",
          "fileExtension='.wm',mimeType='video/x-ms-wm'",
          "fileExtension='.wma',mimeType='audio/x-ms-wma'",
          "fileExtension='.wmd',mimeType='application/x-ms-wmd'",
          "fileExtension='.wmf',mimeType='application/x-msmetafile'",
          "fileExtension='.wml',mimeType='text/vnd.wap.wml'",
          "fileExtension='.wmlc',mimeType='application/vnd.wap.wmlc'",
          "fileExtension='.wmls',mimeType='text/vnd.wap.wmlscript'",
          "fileExtension='.wmlsc',mimeType='application/vnd.wap.wmlscriptc'",
          "fileExtension='.wmp',mimeType='video/x-ms-wmp'",
          "fileExtension='.wmv',mimeType='video/x-ms-wmv'",
          "fileExtension='.wmx',mimeType='video/x-ms-wmx'",
          "fileExtension='.wmz',mimeType='application/x-ms-wmz'",
          "fileExtension='.woff',mimeType='font/x-woff'",
          "fileExtension='.wps',mimeType='application/vnd.ms-works'",
          "fileExtension='.wri',mimeType='application/x-mswrite'",
          "fileExtension='.wrl',mimeType='x-world/x-vrml'",
          "fileExtension='.wrz',mimeType='x-world/x-vrml'",
          "fileExtension='.wsdl',mimeType='text/xml'",
          "fileExtension='.wtv',mimeType='video/x-ms-wtv'",
          "fileExtension='.wvx',mimeType='video/x-ms-wvx'",
          "fileExtension='.x',mimeType='application/directx'",
          "fileExtension='.xaf',mimeType='x-world/x-vrml'",
          "fileExtension='.xaml',mimeType='application/xaml+xml'",
          "fileExtension='.xap',mimeType='application/x-silverlight-app'",
          "fileExtension='.xbap',mimeType='application/x-ms-xbap'",
          "fileExtension='.xbm',mimeType='image/x-xbitmap'",
          "fileExtension='.xdr',mimeType='text/plain'",
          "fileExtension='.xht',mimeType='application/xhtml+xml'",
          "fileExtension='.xhtml',mimeType='application/xhtml+xml'",
          "fileExtension='.xla',mimeType='application/vnd.ms-excel'",
          "fileExtension='.xlam',mimeType='application/vnd.ms-excel.addin.macroEnabled.12'",
          "fileExtension='.xlc',mimeType='application/vnd.ms-excel'",
          "fileExtension='.xlm',mimeType='application/vnd.ms-excel'",
          "fileExtension='.xls',mimeType='application/vnd.ms-excel'",
          "fileExtension='.xlsb',mimeType='application/vnd.ms-excel.sheet.binary.macroEnabled.12'",
          "fileExtension='.xlsm',mimeType='application/vnd.ms-excel.sheet.macroEnabled.12'",
          "fileExtension='.xlsx',mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'",
          "fileExtension='.xlt',mimeType='application/vnd.ms-excel'",
          "fileExtension='.xltm',mimeType='application/vnd.ms-excel.template.macroEnabled.12'",
          "fileExtension='.xltx',mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.template'",
          "fileExtension='.xlw',mimeType='application/vnd.ms-excel'",
          "fileExtension='.xml',mimeType='text/xml'",
          "fileExtension='.xof',mimeType='x-world/x-vrml'",
          "fileExtension='.xpm',mimeType='image/x-xpixmap'",
          "fileExtension='.xps',mimeType='application/vnd.ms-xpsdocument'",
          "fileExtension='.xsd',mimeType='text/xml'",
          "fileExtension='.xsf',mimeType='text/xml'",
          "fileExtension='.xsl',mimeType='text/xml'",
          "fileExtension='.xslt',mimeType='text/xml'",
          "fileExtension='.xsn',mimeType='application/octet-stream'",
          "fileExtension='.xtp',mimeType='application/octet-stream'",
          "fileExtension='.xwd',mimeType='image/x-xwindowdump'",
          "fileExtension='.z',mimeType='application/x-compress'",
          "fileExtension='.zip',mimeType='application/x-zip-compressed'"
        ]
      end
    end
  end
end
