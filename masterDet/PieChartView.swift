

import UIKit

struct Segment {

    // the color of a given segment
    var color: UIColor

    // the value of a given segment
    var value: CGFloat
}

class PieChartView: UIView {

    var segments = [Segment]() {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {

        // get current context
        let ctx = UIGraphicsGetCurrentContext()

       
        let radius = min(frame.size.width, frame.size.height) * 0.5

        // center of the view
        let viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)

        
        let valueCount = segments.reduce(0, {$0 + $1.value})

        
        var startAngle = -CGFloat.pi * 0.5

        for segment in segments {

           
            ctx?.setFillColor(segment.color.cgColor)

         
            let endAngle = startAngle + 2 * .pi * (segment.value / valueCount)

            
            ctx?.move(to: viewCenter)

           
            ctx?.addArc(center: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

            ctx?.fillPath()
            startAngle = endAngle
        }
    }
}
