#include <google/protobuf/descriptor.h>
#include "MessageFactory.h"


namespace kx {
namespace protobufkdb {

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
{}

void MessageFactory::AddProtoImportPath(const std::string& import_path)
{
  // Map each import path so it appears to be located in the current directory
  source_tree->MapPath("", import_path);
}

bool MessageFactory::ImportProtoFile(const std::string& filename, std::string& error)
{
  // Clear any errors which occurred while last importing
  import_errors.str("");

  // Import this .proto, returning any errors which occur.
  if (!importer->Import(filename)) {
    error = import_errors.str();
    return false;
  }

  // Success so add this .proto file to the imported list
  imported_files.push_back(filename);

  return true;
}

void MessageFactory::ListImportedMessageTypes(std::vector<std::string>* output) const
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
      for (auto message_num = 0; message_num < file_desc->message_type_count(); ++message_num) {
        const auto& full_name = file_desc->message_type(message_num)->full_name();
        output->emplace_back(full_name.data(), full_name.length());
      }
    }
  }
}

// See the KXPB_ERROR_COLLECTOR_RECORD comment in MessageFactory.h for why these
// come in two flavours.  absl::string_view streams to std::ostream just as
// std::string does, so the bodies are otherwise identical.
#if KXPB_ERROR_COLLECTOR_RECORD

void MessageFactory::ErrorPrinter::RecordError(absl::string_view filename, int line, int column, absl::string_view message)
{
  output << "Error: " << filename << ":" << line << ":" << column << ": " << message << std::endl;
}

void MessageFactory::ErrorPrinter::RecordWarning(absl::string_view filename, int line, int column, absl::string_view message)
{
  output << "Warning: " << filename << ":" << line << ":" << column << ": " << message << std::endl;
}

#else

void MessageFactory::ErrorPrinter::AddError(const std::string& filename, int line, int column, const std::string& message)
{
  output << "Error: " << filename << ":" << line << ":" << column << ": " << message << std::endl;
}

void MessageFactory::ErrorPrinter::AddWarning(const std::string& filename, int line, int column, const std::string& message)
{
  output << "Warning: " << filename << ":" << line << ":" << column << ": " << message << std::endl;
}

#endif

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

} // namespace protobufkdb
} // namespace kx
