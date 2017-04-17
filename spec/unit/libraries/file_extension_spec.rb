require_relative '../../../libraries/file_extensions'
require 'spec_helper'
include REXML

describe 'IIS::RequestFiltering::FileExtensions::FileExtensionEntry' do

  it 'should create FileExtensionEntry' do
    entry = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.erb', true)
    expect(entry.fileExtension).to eq('.erb')
    expect(entry.allowed).to eq(true)
  end

  it 'should equal fileExtenstionEntry' do
    entry = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.erb', true)
    entry2 = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.erb', true)
    areEqual = entry.equals?(entry2)
    expect(areEqual).to eq(true)
  end

  it 'should equal fileExtenstionEntry with uppercase string' do
    entry = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.erb', 'True')
    entry2 = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.erb', 'true')
    areEqual = entry.equals?(entry2)
    expect(areEqual).to eq(true)
  end

  it 'should NOT equal fileExtenstionEntry with uppercase string' do
    entry = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.erb', true)
    entry2 = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.erb', false)
    areEqual = entry.equals?(entry2)
    expect(areEqual).to eq(false)
  end
end

describe 'IIS::RequestFiltering::FileExtensions::FileExtensionContainer' do

  before (:all) do
    @xml = %q(<appcmd>
    <CONFIG CONFIG.SECTION="system.webServer/security/requestFiltering" path="MACHINE/WEBROOT/APPHOST" overrideMode="Inherit" locked="false">
        <system.webServer-security-requestFiltering>
            <fileExtensions allowUnlisted="true" applyToWebDAV="true">
                <add fileExtension="erb" allowed="false" />
                <add fileExtension=".erb" allowed="false" />
                <add fileExtension=".bob" allowed="True" />
            </fileExtensions>
        </system.webServer-security-requestFiltering>
    </CONFIG>
</appcmd>)
  end

  it 'get_file_extension returns nil with nil fileExtension' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    fileExtensionEntry = container.get_file_extension(nil)
    expect(fileExtensionEntry).to eq(nil)
  end

  it 'has_item should contain fileExtension' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    entry = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.erb', false)
    expect(container.has_item(entry)).to eq(true)
  end

  it 'has_item should NOT contain fileExtension' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    entry = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.erb', true)
    expect(container.has_item(entry)).to eq(false)
  end

  it 'has item should contain fileExtension case-insensitive' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    entry = IIS::RequestFiltering::FileExtensions::FileExtensionEntry.new('.bob', true)
    expect(container.has_item(entry)).to eq(true)
  end
end

describe 'IIS::RequestFiltering::FileExtensions::FileExtensionAppCommandBuilder' do

  before (:all) do
    @xml = %q(<appcmd>
    <CONFIG CONFIG.SECTION="system.webServer/security/requestFiltering" path="MACHINE/WEBROOT/APPHOST" overrideMode="Inherit" locked="false">
        <system.webServer-security-requestFiltering>
            <fileExtensions allowUnlisted="true" applyToWebDAV="true">
                <add fileExtension="erb" allowed="false" />
                <add fileExtension=".erb" allowed="false" />
                <add fileExtension=".bob" allowed="True" />
            </fileExtensions>
        </system.webServer-security-requestFiltering>
    </CONFIG>
</appcmd>)
    @appCmd = "c:\\windows\\inetsrv\\appcmd.exe"
  end

  it 'build_command should return nil' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    cmdBuilder = IIS::RequestFiltering::FileExtensions::FileExtensionAppCommandBuilder.new(container, @appCmd, %w(), %w(erb .erb))
    cmd = cmdBuilder.build_command()
    expect(cmd).to eq(nil)
  end

  it 'build_command exclude should return 1 update' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    cmdBuilder = IIS::RequestFiltering::FileExtensions::FileExtensionAppCommandBuilder.new(container, @appCmd, %w(), %w(.new erb))
    cmd = cmdBuilder.build_command()
    expectedCmd = "#{@appCmd} set config -section:system.webServer/security/requestFiltering /+fileExtensions.[fileExtension='.new',allowed='false']"
    expect(cmd).to eq(expectedCmd)
  end

  it 'build_command exclude should remove extension first then add' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    cmdBuilder = IIS::RequestFiltering::FileExtensions::FileExtensionAppCommandBuilder.new(container, @appCmd, %w(), %w(.bob erb))
    cmd = cmdBuilder.build_command()
    expectedCmd = "#{@appCmd} set config -section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.bob'] /+fileExtensions.[fileExtension='.bob',allowed='false']"
    expect(cmd).to eq(expectedCmd)
  end

  it 'build_command allowed should add 1 entry' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    cmdBuilder = IIS::RequestFiltering::FileExtensions::FileExtensionAppCommandBuilder.new(container, @appCmd, %w(.new), %w())
    cmd = cmdBuilder.build_command()
    expectedCmd = "#{@appCmd} set config -section:system.webServer/security/requestFiltering /+fileExtensions.[fileExtension='.new',allowed='true']"
    expect(cmd).to eq(expectedCmd)
  end

  it 'build_command allowed should remove 1 and add 1 entry' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    cmdBuilder = IIS::RequestFiltering::FileExtensions::FileExtensionAppCommandBuilder.new(container, @appCmd, %w(.erb), %w())
    cmd = cmdBuilder.build_command()
    expectedCmd = "#{@appCmd} set config -section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.erb'] /+fileExtensions.[fileExtension='.erb',allowed='true']"
    expect(cmd).to eq(expectedCmd)
  end

  it 'build_command allowed and excluded' do
    document = Document.new(@xml)
    container = IIS::RequestFiltering::FileExtensions::FileExtensionContainer.new(document)
    cmdBuilder = IIS::RequestFiltering::FileExtensions::FileExtensionAppCommandBuilder.new(container, @appCmd, %w(.erb), %w(.new .bob))
    cmd = cmdBuilder.build_command()
    expectedCmd = "#{@appCmd} set config -section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.erb'] /+fileExtensions.[fileExtension='.erb',allowed='true'] /+fileExtensions.[fileExtension='.new',allowed='false'] /-fileExtensions.[fileExtension='.bob'] /+fileExtensions.[fileExtension='.bob',allowed='false']"
    expect(cmd).to eq(expectedCmd)
  end

end
