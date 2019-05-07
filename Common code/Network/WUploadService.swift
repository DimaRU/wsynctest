////
///  WUploadService.swift
//

import PromiseKit


class WUploadService {
    var uploader: WunderUploader?

    func upload(_ data: Data, filename: String, for taskId: Int, contentType: String = "text/plain; charset=utf-8") -> Promise<WFile>  {

        return WProvider.shared.request(WunderAPI.upload(fileName: filename, fileSize: data.count, contentType: contentType))
            .then { (upload: WUpload) -> Promise<WUpload> in
                WunderUploader(upload: upload, data: data).start()
            }.then { (upload: WUpload) -> Promise<WUpload> in
                WProvider.shared.request(WunderAPI.uploadFinish(uploadId: upload.id))
            }.then { (upload: WUpload) -> Promise<WFile> in
                WProvider.shared.request(WunderAPI.createFile(uploadId: upload.id, taskId: taskId))
        }
    }
}
