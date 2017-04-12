(ns ifconfig-clj.core
  (:require [clojure.data.json :as json]
            [clojure.java.io   :as io]))

(defn -ring-handler [request]
  {:status 200
   :headers {"Content-Type" "text/plain"}
   :body (str (:remote-addr request) "\n")})

; Development mode:
;   lein ring server

; Deployment mode:
;   lein ring uberjar
;   java -jar target/ifconfig-clj-0.0.1-SNAPSHOT-standalone.jar

; Docker mode:
;   lein ring uberjar
;   docker build .
;   docker run -it -p 3000:3000 ifconfig-clj
