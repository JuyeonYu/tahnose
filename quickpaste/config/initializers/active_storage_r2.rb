# Cloudflare R2는 단일 체크섬만 지원하므로 MD5 비활성화
Rails.application.config.after_initialize do
  if defined?(ActiveStorage::Service::S3Service)
    ActiveStorage::Service::S3Service.class_eval do
      private

      def upload_with_single_part(key, io, checksum: nil, content_type: nil, content_disposition: nil, custom_metadata: {})
        instrument :upload, key: key do
          @client.put_object(
            body: io,
            bucket: @bucket,
            key: key,
            content_type: content_type,
            content_disposition: content_disposition,
            metadata: custom_metadata,
            # checksum 파라미터 제거
          )
        end
      end
    end
  end
end