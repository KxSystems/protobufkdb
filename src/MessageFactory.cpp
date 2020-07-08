#include <google/protobuf/descriptor.h>
#include "MessageFactory.h"


// Singleton instance
MessageFactory* MessageFactory::instance = nullptr;

MessageFactory* MessageFactory::Instance()
{
  if (instance == nullptr)
    instance = new MessageFactory();

  return instance;
}

// Initialise all the objects (in the correct order) required to import and
// dynamically create messages
MessageFactory::MessageFactory() :
  error_printer(new ErrorPrinter(import_errors)),
  source_tree(new gpb::compiler::DiskSourceTree),
  importer(new gpb::compiler::Importer(source_tree.get(), error_printer.get())),
  file_db(new gpb::DescriptorPoolDatabase(*importer->pool())),
  desc_pool(new gpb::DescriptorPool(file_db.get())),
  dynamic_factory(new gpb::DynamicMessageFactory())
{
}

void MessageFactory::AddProtoImportPath(const std::string& import_path)
{
  // Map each import path so it appears to be located in the current directory
  source_tree->MapPath("", import_path);
}

bool MessageFactory::ImportProtoFile(const std::string& filename, std::string& error)
{
  // Clear any errors which occurred while last importing
  import_errors.clear();

  // Import this .proto, returning any errors which occur.
  if (!importer->Import(filename)) {
    error = import_errors.str();
    return false;
  }

  // Success so add this .proto file to the imported list
  imported_files.push_back(filename);

  return true;
}

void MessageFactory::ListImportedMessageTypes(std::vector<std::string>* output)
{
  // DescriptorPoolDatabase inherits from DescriptorDatabase but doesn't
  // implement the FindAllMessageNames() method.  
  //
  // However, since we have kept a record of all the .proto files which were
  // sucessfully imported we can lookup each file, find all its message types
  // and amalgamate all the results into a single list.
  for (auto it : imported_files) {
    auto file_desc = desc_pool->FindFileByName(it);
    if (file_desc != nullptr) {
      for (auto message_num = 0; message_num < file_desc->message_type_count(); ++message_num)
        output->push_back(file_desc->message_type(message_num)->full_name());
    }
  }
}

void MessageFactory::ErrorPrinter::AddError(const std::string& filename, int line, int column, const std::string& message)
{
  output << "Import error: " << message << std::endl
    << "File: '" << filename << "', line: " << line << ", column: " << column << std::endl;
}

void MessageFactory::ErrorPrinter::AddWarning(const std::string& filename, int line, int column, const std::string& message)
{
  output << "Import warning: " << message << std::endl
    << "File: '" << filename << "', line: " << line << ", column: " << column << std::endl;
}

gpb::Message* MessageFactory::CreateMessage(const std::string& message_type, gpb::Arena* arena) const
{
  // First check if this message type is present in the generated pool (i.e. it
  // was compiled in) and if so create a new message using the generated factory.
  auto msg_desc = gpb::DescriptorPool::generated_pool()->FindMessageTypeByName(message_type);
  if (msg_desc != nullptr)
    return gpb::MessageFactory::generated_factory()->GetPrototype(msg_desc)->New(arena);

  // Not a compiled in message so look instead in the descriptor pool containing
  // the dynamically imported messages.  If found there create a new message
  // using the dynamic factory.
  const gpb::Descriptor* desc = desc_pool->FindMessageTypeByName(message_type);
  if (desc)
    return dynamic_factory->GetPrototype(desc)->New(arena);

  // Unknown message type.
  return NULL;
}
