(defn nextCollatz [n] (if (even? n) (/ n 2) (+ (* n 3) 1)))

(def naturals (lazy-seq (map #(+ % 1) (range))))

(defn sumOfFirst [n] (apply + (take n naturals)))

(defn idk [n] (
    let [
        times25 (* n 25)
        subOne (- times25 1)
        addOne (+ times25 1)
    ]
    (vector
        (/ (* subOne times25) 50)
        (/ (* addOne times25) 50)
    ))
)
(defn lazy-cat' [colls]
  (lazy-seq
    (if (seq colls)
      (concat (first colls) (lazy-cat' (next colls)))))
)
(defn heightRequiredToDieWhenFallingInABoatInMinecraft [] (lazy-cat' (map idk naturals)))
