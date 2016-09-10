import XCTest
@testable import Advance


class DisplayLinkTests : XCTestCase {
    
    var displayLink: DisplayLink! = nil
    
    override func setUp() {
        displayLink = DisplayLink()
    }
    
    override func tearDown() {
        displayLink = nil
    }
    
    func testCallback() {
        let exp = expectation(description: "callback")
        
        var fulfilled = false
        
        displayLink.callback = { (frame) in
            guard fulfilled == false else { return }
            fulfilled = true
            exp.fulfill()
        }
        
        displayLink.paused = false
        
        waitForExpectations(timeout: 0.5) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
    
    func testPausing() {
        displayLink.paused = false
        
        var gotCallback = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { () -> Void in
            self.displayLink.paused = true
            self.displayLink.callback = { (frame) in
                gotCallback = true
            }
        }
        
        let timeoutDate = Date(timeIntervalSinceNow: 1.0)
        
        repeat {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: timeoutDate)
            if timeoutDate.timeIntervalSinceNow <= 0.0 {
                break
            }
        } while true
        
        XCTAssertEqual(gotCallback, false)
    }

    func testTimestamp() {
        let exp = expectation(description: "callback")
        
        var callbacks = 0
        var lastTimestamp: Double = 0
        
        displayLink.callback = { (frame) in
            XCTAssertTrue(frame.timestamp > lastTimestamp, "timestamp \(frame.timestamp) was not larger than \(lastTimestamp) (frame #\(callbacks))")
            lastTimestamp = frame.timestamp
            
            if callbacks == 10 { // test 10 frames before fulfilling
                exp.fulfill()
            }
            
            callbacks += 1
        }
        
        displayLink.paused = false
        
        waitForExpectations(timeout: 0.5) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
}
