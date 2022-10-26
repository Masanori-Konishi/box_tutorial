;; インピーダンス制御の設定
(defun set-imp-param()
  (send *ri* :remove-force-sensor-offset-rmfo-arms)
  (send *ri* :start-impedance :arms :K-r 200.0 :D-r 300.0  :M-r 1
        :K-p 500.0 :D-p 1000.0 :M-p 5)
  )

;;箱に手を差し込む前の姿勢にIKを解いて遷移
(defun hold-ready-no-reset(&optional (x 420)(width 860)(height 890))
  (send *robot* :fix-leg-to-coords (make-coords))
  (send *robot* :rarm :inverse-kinematics (make-coords :pos (float-vector x (* -1 (/ width 2)) height) :rpy (float-vector (deg2rad 0) (deg2rad 90) (deg2rad 0))))
  (send *robot* :larm :inverse-kinematics (make-coords :pos (float-vector x (/ width 2)  height) :rpy (float-vector (deg2rad 0) (deg2rad 90) (deg2rad 0))))
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  )

(defun hold-ready(&optional (x 300)(width 600)(height 1000))
  (send *robot* :reset-manip-pose)
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :wait-interpolation)
  (hold-cylinder-ready-no-reset x width height)
  )

;IKの重みを変更
(defun hold-ready-no-reset2(&optional (x 420)(width 800)(height 850))
  (send *robot* :fix-leg-to-coords (make-coords))
  (setq target-r (make-coords :pos (float-vector x (* -1 (/ width 2)) height) :rpy (float-vector (deg2rad 0) (deg2rad 90) (deg2rad 0))))
  (setq target-l (make-coords :pos (float-vector x (* 1 (/ width 2)) height) :rpy (float-vector (deg2rad 0) (deg2rad 90) (deg2rad 0))))

  (send *robot* :larm :inverse-kinematics target-l :additional-weight-list (list (list (send *robot* :larm :collar-y :child-link) 0.1)))
  (send *robot* :rarm :inverse-kinematics target-r :additional-weight-list (list (list (send *robot* :rarm :collar-y :child-link) 0.1)))

  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  )

(defun sand-ready-no-reset(&optional (x 420)(width 800)(height 780))
  (send *robot* :fix-leg-to-coords (make-coords))
  (setq target-r (make-coords :pos (float-vector x (* -1 (/ width 2)) height) :rpy (float-vector (deg2rad 0) (deg2rad 0) (deg2rad 0))))
  (setq target-l (make-coords :pos (float-vector x (* 1 (/ width 2)) height) :rpy (float-vector (deg2rad 0) (deg2rad 0) (deg2rad 0))))

  (send *robot* :larm :inverse-kinematics target-l :additional-weight-list (list (list (send *robot* :larm :collar-y :child-link) 1.0)))
  (send *robot* :rarm :inverse-kinematics target-r :additional-weight-list (list (list (send *robot* :rarm :collar-y :child-link) 1.0)))

  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  )


;MSLハンドの指を曲げて箱に手を差し込む準備をする
(defun mslhand-ready(&optional (theta 80))
  (send *robot* :limb :right_hand :angle-vector (float-vector 0 80 theta 0 theta 0))
  (send *ri* :angle-vector (send *robot* :angle-vector) 3000 :right_hand-controller)
  (send *robot* :limb :left_hand :angle-vector (float-vector 0 80 (* -1 theta) 0 (* -1 theta) 0))
  (send *ri* :angle-vector (send *robot* :angle-vector) 3000 :left_hand-controller)
  )

;指を差し込む
(defun hand-insert(&optional (y -120))
  ;(hold-ready-no-reset 420 600 850)
  (movemirror 0 y 0)
  )


(defun mslhand-reset()
  (send *robot* :limb :right_hand :angle-vector #F(0 0 0 0 0 0))
  (send *ri* :angle-vector (send *robot* :angle-vector) 3000 :right_hand-controller) ;;右手だけが動く
  (send *robot* :limb :left_hand :angle-vector #F(0 0 0 0 0 0))
  (send *ri* :angle-vector (send *robot* :angle-vector) 3000 :left_hand-controller)
)

(defun movearms(&optional (x 0)(y 0)(z 0))
  (send *robot* :arms :move-end-pos (float-vector x y z) :world) ;;現在の位置から手先の移動量を指定する方法。デフォルトでは手先座標系。
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :wait-interpolation)
  )

(defun movemirror(&optional (x 0)(y 0)(z 0))
  (send *robot* :rarm :move-end-pos (float-vector x (* -1 y) z) :world)
  (send *robot* :larm :move-end-pos (float-vector x (*  1 y) z) :world)
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  )

(defun sand-box()
  (send *ri* :set-ref-forces
        (list
         (float-vector 0 0 0)
         (float-vector 0 0 0)
         (float-vector 0 -50 0)
         (float-vector 0 50 0)
         )
        3000)
  (unix:sleep 2)
  (send *ri* :set-ref-forces
        (list
         (float-vector 0 0 0)
         (float-vector 0 0 0)
         (float-vector 0 -50 -10) ;;rarm 挟む力をかける場合(float-vector 0 -100  0)
         (float-vector 0 50 -10) ;;larm 挟む力をかける場合(float-vector 0 100  0)
         )
        3000)
  (unix:sleep 2)
  ;;箱を持ち上げる
  (send *robot* :arms :move-end-pos #f(0 0 200) :world) ;;worldをつけることで世界座標系で手先の移動量を指定
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)

  )

(defun liftup-box()

  ;;かかる参照力の設定
  ;;上に持ち上げる力をかける
  (send *ri* :set-ref-forces
        (list
         (float-vector 0 0 0)
         (float-vector 0 0 0)
         (float-vector 0 0 -10) ;;rarm 挟む力をかける場合(float-vector 0 -100  0)
         (float-vector 0 0 -10) ;;larm 挟む力をかける場合(float-vector 0 100  0)
         )
        3000)
  (unix:sleep 2)

  ;;箱を持ち上げる
  (send *robot* :arms :move-end-pos #f(0 0 200) :world) ;;worldをつけることで世界座標系で手先の移動量を指定
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  )

;;箱を置く
(defun put-box()
  (send *robot* :arms :move-end-pos #f(0 0 -200) :world)
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (send *ri* :set-ref-forces
        (list
         (float-vector 0 0 0) ;;rleg
         (float-vector 0 0 0) ;;lleg
         (float-vector 0 0 0) ;;rarm (x, y, z) 単位はニュートン
         (float-vector 0 0 0) ;;larm
         )
        3000)
  )
