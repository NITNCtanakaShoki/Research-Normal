import Fluent
import PostgresKit
import Vapor

struct SendController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    let point = routes.grouped("send", ":from", ":to")
    point.post(use: send)
  }

  func send(req: Request) async throws -> HTTPStatus {
    guard
      let fromUsername = req.parameters.get("from"),
      let toUsername = req.parameters.get("to")
    else {
      throw Abort(.badRequest)
    }

    let content = try req.content.decode(Point.self)
    try await req.db.transaction { transaction in
      let users = try await (transaction as! SQLDatabase).raw(
        """
            SELECT *
              FROM users
             WHERE name = \(bind: fromUsername)
                OR name = \(bind: toUsername)
               FOR UPDATE;
        """
      ).all(decoding: User.self)
      guard users.count == 2 else {
        throw Abort(.notFound, reason: "Not Found User of \(fromUsername) or \(toUsername)")
      }
      _ = try await (transaction as! SQLDatabase).raw(
        """
            UPDATE users
               SET point = point - \(bind: content.point)
             WHERE name = \(bind: fromUsername)
        """
      ).all()
      _ = try await (transaction as! SQLDatabase).raw(
        """
            UPDATE users
               SET point = point + \(bind: content.point)
             WHERE name = \(bind: toUsername)
        """
      ).all()
    }
    return .ok
  }
}

private struct Point: Content {
  var point: Int
}
