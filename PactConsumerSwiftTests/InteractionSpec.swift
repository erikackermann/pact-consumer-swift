import Quick
import Nimble
import PactConsumerSwift

class InteractionSpec: QuickSpec {
  override func spec() {
    var interaction: Interaction?
    beforeEach { interaction = Interaction() }

    describe("interaction state setup") {
      it("it initialises the provider state") {
        expect(interaction?.given("some state").providerState).to(equal("some state"))
      }
      
    }

    describe("json payload"){
      context("pact state") {
        it("includes provider state in the payload") {
          var payload = interaction!.given("state of awesomeness").uponReceiving("an important request is received").payload()

          expect(payload["providerState"] as! String?) == "state of awesomeness"
          expect(payload["description"] as! String?) == "an important request is received"
        }
      }

      context("no provider state") {
        it("doesn not include provider state when not included") {
          var payload = interaction!.uponReceiving("an important request is received").payload()

          expect(payload["providerState"]).to(beNil())
        }
      }

      context("request") {
        var method: PactHTTPMethod = .PUT
        var path = "/path"
        var headers = ["header": "value"]
        var body = "blah"

        it("returns expected request with specific headers and body") {
          var payload = interaction!.withRequest(method: method, path: path, headers: headers, body: body).payload()

          var request = payload["request"] as! [String: AnyObject]
          expect(request["path"] as! String?) == path
          expect(request["method"] as! String?).to(equal("put"))
          expect(request["headers"] as! [String: String]?).to(equal(headers))
          expect(request["body"] as! String?).to(equal(body))
        }

        it("returns expected request without body and headers") {
          var payload = interaction!.withRequest(method:method, path: path).payload()

          var request = payload["request"] as! [String: AnyObject]
          expect(request["path"] as! String?) == path
          expect(request["method"] as! String?).to(equal("put"))
          expect(request["headers"] as! [String: String]?).to(beNil())
          expect(request["body"] as! String?).to(beNil())
        }
      }

      context("response") {
        var statusCode = 200
        var headers = ["header": "value"]
        var body = "body"

        it("returns expected response with specific headers and body") {
          var payload = interaction!.willRespondWith(status: statusCode, headers: headers, body: body).payload()

          var request = payload["response"] as! [String: AnyObject]
          expect(request["status"] as! Int?) == statusCode
          expect(request["headers"] as! [String: String]?).to(equal(headers))
          expect(request["body"] as! String?).to(equal(body))
        }
      }
    }
  }
}
