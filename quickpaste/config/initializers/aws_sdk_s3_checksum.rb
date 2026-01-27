# frozen_string_literal: true

Aws.config.update(
  s3: {
    # R2 호환: AWS SDK가 x-amz-checksum-* 를 추가로 붙이지 않게 함
    request_checksum_calculation: "when_required",
    response_checksum_validation: "when_required"
  }
)