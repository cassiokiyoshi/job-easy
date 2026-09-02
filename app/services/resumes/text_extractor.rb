require "docx"

module Resumes
  # Downloads a resume's attached .docx and returns its plain text.
  class TextExtractor
    def initialize(resume)
      @resume = resume
    end

    def call
      Tempfile.create(["resume", ".docx"]) do |file|
        file.binmode
        file.write(@resume.cv_file.blob.download)
        file.rewind

        Docx::Document.open(file.path).text
      end
    end
  end
end
