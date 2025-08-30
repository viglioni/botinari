defmodule Bsky.Blob do
  @moduledoc """
  Uploads a picture to bsky.
  """

  @post_blob_url "https://bsky.social/xrpc/com.atproto.repo.uploadBlob"

  def upload_image(image, authorization) do
    Http.post_body(
      @post_blob_url,
      image,
      [authorization, "Content-Type": "image/jpeg"]
    )
  end
end
