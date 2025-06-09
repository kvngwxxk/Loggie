import Testing
import Foundation
@testable import Loggie

@Test
func testLogFunctionOutput() throws {
    Loggie.showEmoji = true
    Loggie.showEmojiInCommonLog = false
    Loggie.showLevelInCommonLog = false
    Loggie.useOSLog = true
    Loggie.useFileLogging = true
    
    let something = "Something!?"
    
    log("LOG SOMETHING : \(something)")
    debug("DEBUG TEST MESSAGE")
    info("INFO TEST MESSAGE")
    error("ERROR TEST MESSAGE")
    warning("WARNING TEST MESSAGE")
    
    Loggie.log("STATIC LOG TEST MESSAGE")
    Loggie.debug("STATIC DEBUG TEST MESSAGE")
    Loggie.info("STATIC INFO TEST MESSAGE")
    Loggie.error("STATIC ERROR TEST MESSAGE")
    Loggie.warning("STATIC WARNING TEST MESSAGE")
    
    fflush(stdout)
}
