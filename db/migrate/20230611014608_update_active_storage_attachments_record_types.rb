class UpdateActiveStorageAttachmentsRecordTypes < ActiveRecord::Migration[7.0]
  def up
    ActiveStorage::Attachment.where(record_type: "Cover")
      .find_each do |attachment|
      attachment.update! record_type: "Submission"
    end
  end

  def down
    ActiveStorage::Attachment.where(record_type: "Submission")
      .find_each do |attachment|
      attachment.update! record_type: "Cover"
    end
  end
end
