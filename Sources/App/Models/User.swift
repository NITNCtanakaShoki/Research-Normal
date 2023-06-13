import Vapor
import Fluent

final class User: Model, Content {
    
    static var schema = "users"
    
    @ID(custom: "name")
    var id: String?
    
    @Field(key: "point")
    var point: Int
    
    var name: String? {
        get { id }
        set { id = newValue }
    }
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(name: String, point: Int = 0) {
        self.name = name
        self.point = point
    }
}
