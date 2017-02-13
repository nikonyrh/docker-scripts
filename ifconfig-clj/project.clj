(defproject ifconfig-clj "0.0.1-SNAPSHOT"
  :description "FIXME: write description"
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [org.clojure/data.json "0.2.6"]
                 [ring/ring-core "1.5.1"]
                 [uswitch/lambada "0.1.2"]]
  :javac-options ["-target" "1.6" "-source" "1.6" "-Xlint:-options"]
  :java-source-paths ["src/java"]
  :aot [ifconfig-clj.core]
  :main ifconfig-clj.core
  :plugins [[lein-ring "0.11.0"]]
  :ring {:handler ifconfig-clj.core/-ring-handler})
