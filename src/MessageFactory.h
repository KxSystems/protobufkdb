#ifndef __MESSAGE_FACTORY_H__
#define __MESSAGE_FACTORY_H__

#include <string>
#include <iostream>
#include <sstream>
#include <memory>

#include <google/protobuf/message.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/arena.h>
#include <google/protobuf/compiler/importer.h>
#include <google/protobuf/dynamic_message.h>

namespace gpb = ::google::protobuf;


class MessageFactory
{
private:
  static class MessageFactory* instance;

  class ErrorPrinter; // forward declaration

  // List of errors and warnings (if any) which occurred while parsing the last
  // proto file. 
  std::ostringstream import_errors; 

  // Helper class used by the Importer to populate import_errors.
  std::unique_ptr<ErrorPrinter> error_printer;

  // DiskSourceTree represents a directory tree containing proto files and loads
  // files from locations on disk.  Used by the Importer to resolve import
  // statements.  Multiple mappings can be set up to map locations in the
  // DiskSourceTree to locations in the physical filesystem.
  std::unique_ptr<gpb::compiler::DiskSourceTree> source_tree;

  // Simple interface for parsing .proto files.  This wraps the process of
  // opening the file, parsing it with a Parser, recursively parsing all its
  // imports, and then cross-linking the results to produce a FileDescriptor.
  std::unique_ptr<gpb::compiler::Importer> importer;

  // The descriptor database being produced by the above importer.
  std::unique_ptr<gpb::DescriptorPoolDatabase> file_db;

  // A descriptor pool created from the above file_db.
  std::unique_ptr<gpb::DescriptorPool> desc_pool;

  // Constructs implementations of Message which can emulate types which are not
  // known at compile-time.
  std::unique_ptr<gpb::DynamicMessageFactory> dynamic_factory;

  // Vector of .proto files which have been successfully imported.
  std::vector<std::string> imported_files;

private:
  MessageFactory();

  // Private class used by the proto importer to return any errors or warnings
  // which occurred while parsing a proto file.
  class ErrorPrinter : public gpb::compiler::MultiFileErrorCollector
  {
  public:
    explicit ErrorPrinter(std::ostringstream& oss) : output(oss) {}

    void AddError(const std::string& filename, int line, int column, const std::string& message) override;
    void AddWarning(const std::string& filename, int line, int column, const std::string& message) override;

  private:
    std::ostringstream& output;
  };

public:
  /**
   * @brief Returns the singleton instance.
   *
   * @return MessageFactory object
  */
  static MessageFactory* Instance();

  /**
   * @brief Creates a protobuf message using the message_type lookup mapping
   * defined by the factory
   *
   * @param message_type  String representation of a message type.  Must be the
   * same as the message name in its .proto definition.
   * @param arena         Optional google arena in which to create the message
   * @return              New protobuf message        
  */
  gpb::Message* CreateMessage(const std::string& message_type, gpb::Arena* arena = NULL) const;

  /**
   * @brief Adds a path to be searched when dynamically importing .proto file
   * definitions.  Can be called more than once to specify multiple import
   * locations.
   *
   * @param import_path Path to be searched for proto file definitions.  Can be
   * absolute or relative.
  */
  void AddProtoImportPath(const std::string& import_path);

  /**
   * @brief Dynamically imports a .proto file definition into the factory,
   * allowing the messages defined in that file to be created by the factory.
   *
   * @param filename  The name of the .proto file to be imported.  Must not
   * contain any directory specifiers - directory search locations should be
   * setup up beforehand using AddProtoImportPath().
   * @param error     If the file fails to parse, the string will be set to the
   * set of errors and warnings which occurred.
   * @return          True on success, false otherwise.
  */
  bool ImportProtoFile(const std::string& filename, std::string& error);

  /**
   * @brief Returns a list of the message types which have been successfully
   * imported.
   *
   * @param output  The list of imported message types.
  */
  void ListImportedMessageTypes(std::vector<std::string>* output) const;
};

#endif // __MESSAGE_FACTORY_H__
