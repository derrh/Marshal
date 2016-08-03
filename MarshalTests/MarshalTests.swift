//
//  M A R S H A L
//
//       ()
//       /\
//  ()--'  '--()
//    `.    .'
//     / .. \
//    ()'  '()
//
//

import XCTest
@testable import Marshal

class MarshalTests: XCTestCase {
    
    let object: JSONObject = ["bigNumber": NSNumber(value: 10_000_000_000_000), "foo" : (2 as NSNumber), "str": "Hello, World!", "array" : [1,2,3,4,7], "object": ["foo" : (3 as NSNumber), "str": "Hello, World!"], "url":"http://apple.com",  "junk":"garbage", "urls":["http://apple.com", "http://github.com"]]
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasics() {
        self.measure {
            let str: String = try! self.object.value(key: "str")
            XCTAssertEqual(str, "Hello, World!")
            //    var foo1: String = try object.value(key: "foo")
            let foo2: Int = try! self.object.value(key: "foo")
            XCTAssertEqual(foo2, 2)
            let bigNumber: Int64 = try! self.object.value(key: "bigNumber")
            XCTAssertEqual(bigNumber, 10_000_000_000_000)
            let foo3: Int? = try! self.object.value(key: "foo")
            XCTAssertEqual(foo3, 2)
            let foo4: Int? = try! self.object.value(key: "bar")
            XCTAssertEqual(foo4, .none)
            let arr: [Int] = try! self.object.value(key: "array")
            XCTAssert(arr.count == 5)
            let obj: JSONObject = try! self.object.value(key: "object")
            XCTAssert(obj.count == 2)
            let innerfoo: Int = try! obj.value(key: "foo")
            XCTAssertEqual(innerfoo, 3)
            let innerfoo2: Int = try! self.object.value(key: "object.foo")
            XCTAssertEqual(innerfoo2, 3)
            let url:URL = try! self.object.value(key: "url")
            XCTAssertEqual(url.host, "apple.com")
            
            let expectation = self.expectation(description: "error")
            do {
                let _:Int? = try self.object.value(key: "junk")
            }
            catch {
                let jsonError = error as! MarshalError
                expectation.fulfill()
                guard case MarshalError.typeMismatchWithKey = jsonError else {
                    XCTFail("shouldn't get here")
                    return
                }
            }
            
            let urls:[URL] = try! self.object.value(key: "urls")
            XCTAssertEqual(urls.first!.host, "apple.com")
            
            self.waitForExpectations(timeout: 1, handler: nil)
        }
    }
    
    func testOptionals() {
        var str:String = try! object <| "str"
        XCTAssertEqual(str, "Hello, World!")
        
        var optStr:String? = try! object <| "str"
        XCTAssertEqual(optStr, "Hello, World!")
        
        optStr = try! object <| "not found"
        XCTAssertEqual(optStr, .none)
        
        let ra:[Int] = try! object <| "array"
        XCTAssertEqual(ra[0], 1)
        
        var ora:[Int]? = try! object <| "array"
        XCTAssertEqual(ora![0], 1)
        
        ora = try! object <| "no key"
        XCTAssertNil(ora)
        
        let ex = self.expectation(description: "not found")
        do {
            str = try object <| "not found"
        }
        catch {
            if case MarshalError.keyNotFound = error {
                ex.fulfill()
            }
        }
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testErrors() {
        var expectation = self.expectation(description: "not found")
        let str: String = try! self.object.value(key: "str")
        XCTAssertEqual(str, "Hello, World!")
        do {
            let _:Int = try object.value(key: "no key")
        }
        catch {
            if case MarshalError.keyNotFound = error {
                expectation.fulfill()
            }
        }
        
        expectation = self.expectation(description: "key mismatch")
        do {
            let _:Int = try object.value(key: "str")
        }
        catch {
            if case MarshalError.typeMismatchWithKey = error {
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDicionary() {
        let path = Bundle(for: self.dynamicType).path(forResource: "TestDictionary", ofType: "json")!
        var data = try! Data(contentsOf: URL(fileURLWithPath: path))
        var json:JSONObject = try! JSONParser.parseObject(data)
        let url:URL = try! json.value(key: "meta.next")
        XCTAssertEqual(url.host, "apple.com")
        var people:[JSONObject] = try! json.value(key: "list")
        var person = people[0]
        let city:String = try! person.value(key: "address.city")
        XCTAssertEqual(city, "Cupertino")
        
        data = try! json.jsonData()
        
        json = try! JSONParser.parseObject(data)
        people = try! json.value(key: "list")
        person = people[1]
        let dead = try! !person.value(key: "living")
        XCTAssertTrue(dead)
    }
    
    func testSimpleArray() {
        let path = Bundle(for: self.dynamicType).path(forResource: "TestSimpleArray", ofType: "json")!
        var data = try! Data(contentsOf: URL(fileURLWithPath: path))
        var ra = try! JSONSerialization.jsonObject(with: data, options: []) as! [AnyObject]
        XCTAssertEqual(ra.first as? Int, 1)
        XCTAssertEqual(ra.last as? String, "home")
        
        data = try! ra.jsonData()
        ra = try! JSONSerialization.jsonObject(with: data, options: []) as! [AnyObject]
        XCTAssertEqual(ra.first as? Int, 1)
        XCTAssertEqual(ra.last as? String, "home")
    }
    
    func testObjectArray() {
        let path = Bundle(for: self.dynamicType).path(forResource: "TestObjectArray", ofType: "json")!
        var data = try! Data(contentsOf: URL(fileURLWithPath: path))
        var ra:[JSONObject] = try! JSONParser.parseArray(data)
        
        var obj:JSONObject = ra[0]
        XCTAssertEqual(try! obj.value(key: "n") as Int, 1)
        XCTAssertEqual(try! obj.value(key: "str") as String, "hello")
        
        data = try! ra.jsonData()
        
        ra = try! JSONParser.parseArray(data)
        obj = ra[1]
        XCTAssertEqual(try! obj.value(key: "str") as String, "world")
    }
    
    func testNested() {
        let dict = ["type": "connected",
                    "payload": [
                        "team": [
                            "id": "teamId",
                            "name": "teamName"
                        ]
            ]
        ]
        
        let teamId:String = try! dict.value(key: "payload.team.id")
        XCTAssertEqual(teamId, "teamId")
    }
    
    func testCustomObjects() {
        let path = Bundle(for: self.dynamicType).path(forResource: "People", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let obj = try! JSONParser.parseObject(data)
        let people:[Person] = try! obj.value(key: "people")
        let person:Person = try! obj.value(key: "person")
        XCTAssertEqual(people.first!.firstName, "Jason")
        XCTAssertEqual(person.firstName, "Jason")
        XCTAssertEqual(person.score, 42)
        XCTAssertEqual(people.last!.address!.city, "Cupertino")
    }
    
    enum MyEnum:String {
        case One
        case Two
        case Three
        
    }
    
    enum MyIntEnum:Int {
        case one = 1
        case two = 2
    }
    
    
    func testEnum() {
        let json = ["one":"One", "two":"Two", "three":"Three", "four":"Junk", "iOne":NSNumber(value: 1), "iTwo":NSNumber(value: 2)]
        let one:MyEnum = try! json.value(key: "one")
        XCTAssertEqual(one, MyEnum.One)
        let two:MyEnum = try! json.value(key: "two")
        XCTAssertEqual(two, MyEnum.Two)
        
        let nope:MyEnum? = try! json.value(key: "junk")
        XCTAssertEqual(nope, .none)
        
        let expectation = self.expectation(description: "enum test")
        do {
            let _:MyEnum = try json.value(key: "four")
        }
        catch {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        let iOne:MyIntEnum = try! json.value(key: "iOne")
        XCTAssertEqual(iOne, MyIntEnum.one)
        
    }
    

    func testSet() {
        let path = Bundle(for: self.dynamicType).path(forResource: "TestSimpleSet", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! JSONObject
        
        let first:Set<Int> = try! json.value(key: "first")
        XCTAssertEqual(first.count, 5)
        let second:Set<Int> = try! json.value(key: "second")
        XCTAssertEqual(second.count, 5)
        
        let nope:Set<Int>? = try! json.value(key: "junk")
        XCTAssertEqual(nope, .none)
    }
    
    func testSwiftBasicTypes() {
        let object: JSONObject = ["int8": NSNumber(value: 100), "int16": NSNumber(value: 32_000), "int32": NSNumber(value: 2_100_000_000), "int64": NSNumber(value: 9_000_000_000_000_000_000)]

        let int8: Int8 = try! object.value(key: "int8")
        XCTAssertEqual(int8, 100)
        let int16: Int16 = try! object.value(key: "int16")
        XCTAssertEqual(int16, 32_000)
        let int32: Int32 = try! object.value(key: "int32")
        XCTAssertEqual(int32, 2_100_000_000)
        let int64: Int64 = try! object.value(key: "int64")
        XCTAssertEqual(int64, 9_000_000_000_000_000_000)
        
        
        let soBig: UInt64 = 18_000_000_000_000_000_000
        let unsigned: JSONObject = ["uint8": NSNumber(value: 200), "uint16": NSNumber(value: 65_000), "uint32": NSNumber(value: 4_200_000_000), "uint64": NSNumber(value: soBig), "char": "S"]

        let uint8: UInt8 = try! unsigned.value(key: "uint8")
        XCTAssertEqual(uint8, 200)
        let uint16: UInt16 = try! unsigned.value(key: "uint16")
        XCTAssertEqual(uint16, 65_000)
        let uint32: UInt32 = try! unsigned.value(key: "uint32")
        XCTAssertEqual(uint32, 4_200_000_000)
        let uint64: UInt64 = try! unsigned.value(key: "uint64")
        XCTAssertEqual(uint64, 18_000_000_000_000_000_000)
        
        let char: Character = try! unsigned.value(key: "char")
        XCTAssertEqual(char, "S")
        
        let trueAndFalse: JSONObject = ["falsy": NSNumber(value: false), "truthy": NSNumber(value: true)]
        let truthy: Bool = try! trueAndFalse.value(key: "truthy")
        XCTAssertTrue(truthy)
        
        let falsy: Bool = try! trueAndFalse.value(key: "falsy")
        XCTAssertFalse(falsy)
    }
}

struct Address: Unmarshaling {
    let street:String
    let city:String
    init(object json: Marshaled) throws {
        street = try json.value(key: "street")
        city = try json.value(key: "city")
    }
}

struct Person: Unmarshaling {
    let firstName:String
    let lastName:String
    let score:Int
    let address:Address?
    init(object json: Marshaled) throws {
        firstName = try json.value(key: "first")
        lastName = try json.value(key: "last")
        score = try json.value(key: "score")
        address = try json.value(key: "address")
    }
}
