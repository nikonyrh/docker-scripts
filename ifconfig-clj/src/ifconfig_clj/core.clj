(ns ifconfig-clj.core
  (:require [clojure.data.json :as json])
  (:gen-class))

; A very basic JSON response with some ad-hoc pretty printing.
(defn handler [request]
  {:status 200
   :headers {"Content-Type" "application/json"}
   :body (-> {:remote-addr (:remote-addr request)
              :user-agent ((:headers request) "user-agent")}
             json/write-str
             (clojure.string/replace #"\",\"" "\",\n  \"")
             (clojure.string/replace #"\":\"" "\": \"")
             (clojure.string/replace #"^\{\"" "{ \""))})
