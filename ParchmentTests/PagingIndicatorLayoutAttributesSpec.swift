import Foundation
import Quick
import Nimble
@testable import Parchment

struct CustomPagingTheme: PagingTheme {
  let font: UIFont = UIFont.systemFontOfSize(15)
  let textColor: UIColor = .blueColor()
  let selectedTextColor: UIColor = .redColor()
  let indicatorColor: UIColor = .greenColor()
}

struct CustomPagingOptions: PagingOptions {
  let headerHeight: CGFloat = 40
  var theme: PagingTheme = CustomPagingTheme()
  let indicatorOptions: PagingIndicatorOptions = .Visible(
    height: 20,
    zIndex: Int.max,
    insets: UIEdgeInsets())
}

class PagingIndicatorLayoutAttributesSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingIndicatorLayoutAttributes") {
      
      let layoutAttributes = PagingIndicatorLayoutAttributes()
      let options: PagingOptions = CustomPagingOptions()
      
      beforeEach {
        layoutAttributes.configure(options)
      }
      
      describe("when configuring with options") {
        
        it("should configure the correct properties") {
          expect(layoutAttributes.backgroundColor).to(equal(UIColor.greenColor()))
          expect(layoutAttributes.frame.height).to(equal(20))
          expect(layoutAttributes.frame.origin.y).to(equal(20))
          expect(layoutAttributes.zIndex).to(equal(Int.max))
        }
        
      }
      
      describe("when updating with metrics") {
        
        let from = PagingIndicatorMetric(
          frame: CGRect(x: 0, y: 0, width: 200, height: 0),
          insets: .Left(50))
        
        let to = PagingIndicatorMetric(
          frame: CGRect(x: 200, y: 0, width: 100, height: 0),
          insets: .Right(50))
        
        it("has the correct frame for the initial metric") {
          layoutAttributes.update(from: from, to: to, progress: 0)
          expect(layoutAttributes.frame).to(equal(CGRect(x: 50, y: 20, width: 150, height: 20)))
        }
        
        it("has the correct frame for the final metric") {
          layoutAttributes.update(from: from, to: to, progress: 1)
          expect(layoutAttributes.frame).to(equal(CGRect(x: 200, y: 20, width: 50, height: 20)))
        }
        
        it("tweens correctly between metrics") {
          layoutAttributes.update(from: from, to: to, progress: 0.5)
          expect(layoutAttributes.frame).to(equal(CGRect(x: 125, y: 20, width: 100, height: 20)))
        }
        
      }
      
    }
    
  }
  
}
