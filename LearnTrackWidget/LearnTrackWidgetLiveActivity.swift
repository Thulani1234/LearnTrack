//
//  LearnTrackWidgetLiveActivity.swift
//  LearnTrackWidget
//
//  Created by COBSCCOMP242P-028 on 2026-05-04.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LearnTrackWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LearnTrackWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LearnTrackWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LearnTrackWidgetAttributes {
    fileprivate static var preview: LearnTrackWidgetAttributes {
        LearnTrackWidgetAttributes(name: "World")
    }
}

extension LearnTrackWidgetAttributes.ContentState {
    fileprivate static var smiley: LearnTrackWidgetAttributes.ContentState {
        LearnTrackWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LearnTrackWidgetAttributes.ContentState {
         LearnTrackWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LearnTrackWidgetAttributes.preview) {
   LearnTrackWidgetLiveActivity()
} contentStates: {
    LearnTrackWidgetAttributes.ContentState.smiley
    LearnTrackWidgetAttributes.ContentState.starEyes
}
