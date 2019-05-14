//
//  AppDataSyncPush.swift
//  wsync
//
//  Created by Dmitriy Borovikov on 29.06.2018.
//  Copyright © 2018 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import PromiseKit

extension AppDataSync {
    
    // Modify object
    // Todo:
    // 1. Изменить локальный объект
    // 2. Отмаркировать объект
    // 3. Создать и поставить запрос в очередь
    // 4. Запустить push (остановить pull)
    func pushWObject<T: WObject>(wobject: T) {
//        self.appData.update
        //
    }
    
    // Push
    public func push() {
        self.syncState = .push
    }
    
    
    
}
