require "docx"

module Resumes
  # Downloads a resume's attached .docx and returns its plain text.
  class TextExtractor
    def initialize(resume)
      @resume = resume
    end

    def call
      blob = @resume.cv_file.blob
      Tempfile.create(["resume", ".docx"]) do |file|
        file.binmode
        file.write(blob.download)
        file.rewind

        doc = Docx::Document.open(file.path)
        doc.text
      end
    end
  end
end
