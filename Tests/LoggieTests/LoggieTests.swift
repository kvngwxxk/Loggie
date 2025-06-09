import Testing
import Foundation
@testable import Loggie

@Test
func testLogFunctionOutput() throws {
    Loggie.showEmoji = true
    Loggie.showEmojiInCommonLog = true
    Loggie.showLevelInCommonLog = true
    Loggie.useOSLog = true
    Loggie.useFileLogging = true
    
    log("A simple log message")
    info("Informational event")
    debug("Debugging details")
    warning("Something looks wrong")
    error("Something went wrong")
    
//    Loggie.log("STATIC LOG TEST MESSAGE")
//    Loggie.debug("STATIC DEBUG TEST MESSAGE")
//    Loggie.info("STATIC INFO TEST MESSAGE")
//    Loggie.error("STATIC ERROR TEST MESSAGE")
//    Loggie.warning("STATIC WARNING TEST MESSAGE")
    
    fflush(stdout)
}
