import XCTest
#if GRDBCIPHER
    import GRDBCipher
#elseif GRDBCUSTOMSQLITE
    import GRDBCustomSQLite
#else
    import GRDB
#endif

class TruncateOptimizationTests: GRDBTestCase {
    // https://www.sqlite.org/c3ref/update_hook.html
    //
    // > In the current implementation, the update hook is not invoked [...]
    // > when rows are deleted using the truncate optimization.
    //
    // https://www.sqlite.org/lang_delete.html#truncateopt
    //
    // > When the WHERE is omitted from a DELETE statement and the table
    // > being deleted has no triggers, SQLite uses an optimization to erase
    // > the entire table content without having to visit each row of the
    // > table individually.
    //
    // Here we test that the truncate optimization does not prevent
    // transaction observers from observing individual deletions.

    class DeletionObserver : TransactionObserver {
        private var notify: ([String: Int]) -> Void
        private var deletionEvents: [String: Int] = [:]
        
        // Notifies table names with the number of deleted rows
        init(_ notify: @escaping ([String: Int]) -> Void) {
            self.notify = notify
        }
        
        func observes(eventsOfKind eventKind: DatabaseEventKind) -> Bool {
            return true
        }
        
        #if SQLITE_ENABLE_PREUPDATE_HOOK
        func databaseWillChange(with event: DatabasePreUpdateEvent) { }
        #endif
        
        func databaseDidChange(with event: DatabaseEvent) {
            if case .delete = event.kind {
                deletionEvents[event.tableName, default: 0] += 1
            }
        }
        
        func databaseWillCommit() throws { }
        
        func databaseDidCommit(_ db: Database) {
            if !deletionEvents.isEmpty {
                notify(deletionEvents)
            }
            deletionEvents = [:]
        }
        
        func databaseDidRollback(_ db: Database) {
            deletionEvents = [:]
        }
    }
    
    func testExecuteDelete() throws {
        let dbQueue = try makeDatabaseQueue()
        
        var deletionEvents: [[String: Int]] = []
        let observer = DeletionObserver { deletionEvents.append($0) }
        dbQueue.add(transactionObserver: observer, extent: .databaseLifetime)
        
        try dbQueue.inDatabase { db in
            try db.execute("CREATE TABLE t(a)")
            
            try db.execute("INSERT INTO t VALUES (NULL)")
            try db.execute("INSERT INTO t VALUES (NULL)")
            deletionEvents = []
            try db.execute("DELETE FROM t")
            XCTAssertEqual(deletionEvents.count, 1)
            XCTAssertEqual(deletionEvents[0], ["t": 2])
            
            try db.execute("INSERT INTO t VALUES (NULL)")
            deletionEvents = []
            try db.execute("DELETE FROM t")
            XCTAssertEqual(deletionEvents.count, 1)
            XCTAssertEqual(deletionEvents[0], ["t": 1])
        }
    }
    
    func testExecuteDeleteWithPreparedStatement() throws {
        let dbQueue = try makeDatabaseQueue()
        
        var deletionEvents: [[String: Int]] = []
        let observer = DeletionObserver { deletionEvents.append($0) }
        dbQueue.add(transactionObserver: observer, extent: .databaseLifetime)
        
        try dbQueue.inDatabase { db in
            try db.execute("CREATE TABLE t(a)")
            let deleteStatement = try db.makeUpdateStatement("DELETE FROM t")
            
            try db.execute("INSERT INTO t VALUES (NULL)")
            try db.execute("INSERT INTO t VALUES (NULL)")
            deletionEvents = []
            try deleteStatement.execute()
            XCTAssertEqual(deletionEvents.count, 1)
            XCTAssertEqual(deletionEvents[0], ["t": 2])
            
            try db.execute("INSERT INTO t VALUES (NULL)")
            deletionEvents = []
            try deleteStatement.execute()
            XCTAssertEqual(deletionEvents.count, 1)
            XCTAssertEqual(deletionEvents[0], ["t": 1])
        }
    }
    
    func testDropTable() throws {
        // Preventing the truncate optimization requires GRDB to fiddle with
        // sqlite3_set_authorizer. When badly done, this can prevent DROP TABLE
        // statements from dropping tables.
        //
        // SQLite3 authorizers can perform during both compilation and
        // execution of statements.
        //
        // Here we test that grouping compilation and execution of DROP TABLE
        // statement does the right thing.
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.execute("CREATE TABLE t(a)")
            try db.execute("INSERT INTO t VALUES (NULL)")
            try db.execute("DROP TABLE t") // compile + execute
            try XCTAssertFalse(db.tableExists("t"))
        }
    }
    
    func testDropTableWithPreparedStatement() throws {
        // Preventing the truncate optimization requires GRDB to fiddle with
        // sqlite3_set_authorizer. When badly done, this can prevent DROP TABLE
        // statements from dropping tables.
        //
        // SQLite3 authorizers can perform during both compilation and
        // execution of statements.
        //
        // Here we test that splitting compilation from execution of DROP TABLE
        // statement does the right thing.
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.execute("CREATE TABLE t(a)")
            try db.execute("INSERT INTO t VALUES (NULL)")
            let dropStatement = try db.makeUpdateStatement("DROP TABLE t") // compile...
            try dropStatement.execute() // ... then execute
            try XCTAssertFalse(db.tableExists("t"))
        }
    }
}
