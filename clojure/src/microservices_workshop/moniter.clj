(ns microservices-workshop.moniter
  (:gen-class)
  (:require [langohr.core      :as rmq]
            [langohr.channel   :as lch]
            [langohr.queue     :as lq]
            [langohr.consumers :as lc]
            [langohr.basic     :as lb]
            [langohr.exchange  :as le]
            [microservices-workshop.core :as core]))

(defn message-handler
  [ch {:keys [content-type delivery-tag] :as meta} ^bytes payload]
  (println (format " [x] Received %s" (String. payload "UTF-8"))))

(defn -main [& args]
  (let [host (first args)
        bus (second args)
        {:keys [conn ch]} (core/create-connection host bus)]
    (println (format " [*] Waiting for solutions on the %s bus... To exit press CTRL+C" bus))
    (core/subscribe ch message-handler)))
