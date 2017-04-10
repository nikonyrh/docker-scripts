(ns ifconfig-clj.core
  (:require [clojure.data.json :as json]
            [clojure.java.io   :as io]
            [uswitch.lambada.core :refer [deflambdafn]]))


(defn handle-lambda [event]
  (println "Got the following event: " (pr-str event))
  {:status "ok"})


(deflambdafn ifconfig.lambda [in out ctx]
  (let [event (-> in io/reader json/read)
        res   (handle-lambda event)]
    (with-open [w (io/writer out)]
      (json/write res w))))


(defn -ring-handler [request]
  {:status 200
   :headers {"Content-Type" "text/plain"}
   :body (str (:remote-addr request) "\n")})
