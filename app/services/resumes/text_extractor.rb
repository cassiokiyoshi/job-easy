require "docx"

module Resumes
  # Downloads a resume's attached .docx and returns its plain text.
  class TextExtractor
    def initialize(resume)
      @resume = resume
    end

    def call
      @resume.cv_file.blob.open do |file|
        Docx::Document.open(file.path).text
      end
    end
  end
end
