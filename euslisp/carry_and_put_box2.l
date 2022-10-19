

(defun hold-ready-no-reset(&optional (x 420)(width 800)(height 890))
  ;; 逆運動学(Inverse Kinematics)を用いたロボットの姿勢の司令方法
  ;;(make-coords)で生成した位置姿勢に右手が来るように、逆運動学を解いて関節角度を求める。
  (send *robot* :rarm :inverse-kinematics (make-coords :pos (float-vector x (* -1 (/ width 2)) height) :rpy (float-vector (deg2rad 0) (deg2rad 90) (deg2rad 0)))) 
  (send *robot* :larm :inverse-kinematics (make-coords :pos (float-vector x (/ width 2)  height) :rpy (float-vector (deg2rad 0) (deg2rad 90) (deg2rad 0))))
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000) 
  (send *ri* :wait-interpolation)
  )

(defun hold-ready(&optional (x 300)(width 600)(height 1000))
  (send *robot* :reset-manip-pose)
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000) 
  (send *ri* :wait-interpolation)
  (hold-cylinder-ready-no-reset x width height)
  )

(defun mslhand_ready()
  (send *robot* :limb :right_hand :angle-vector #F(0 80 80 0 80 0))
  (send *ri* :angle-vector (send *robot* :angle-vector) 3000 :right_hand-controller) ;;右手だけが動く
  (send *robot* :limb :left_hand :angle-vector #F(0 80 -80 0 -80 0))
  (send *ri* :angle-vector (send *robot* :angle-vector) 3000 :left_hand-controller)
)

(defun hold-ready2()
  (hold-ready-no-reset 420 600 890)
  )

(defun mslhand_reset()
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

(defun sand-box2()
  ;; インピーダンス制御の設定
  (send *ri* :remove-force-sensor-offset-rmfo-arms)
  (send *ri* :start-impedance :arms :K-r 200.0 :D-r 300.0  :M-r 1
        :K-p 500.0 :D-p 1000.0 :M-p 5)

  ;;かかる参照力の設定
  ;;上に持ち上げる力をかける
  (send *ri* :set-ref-forces
        (list
         (float-vector 0 0 0)
         (float-vector 0 0 0)
         (float-vector 0 0 -10) ;;rarm
         (float-vector 0 0 -10) ;;larm
         )
        3000)
  (unix:sleep 2)

  ;;箱を持ち上げる
  (send *robot* :arms :move-end-pos #f(0 0 200) :world) ;;worldをつけることで世界座標系で手先の移動量を指定
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :wait-interpolation)
  )


(defun sand-box()
  ;; インピーダンス制御の設定
  (send *ri* :remove-force-sensor-offset-rmfo-arms) ;;手先力センサのオフセットを除去。
  (send *ri* :start-impedance :arms :K-r 200.0 :D-r 300.0  :M-r 1
        :K-p 500.0 :D-p 1000.0 :M-p 5) ;;インピーダンス制御の設定。K(バネ)D(ダンパ)M(慣性)、　r(回転)、p(並進)

  ;;箱を持つ
  (send *robot* :arms :move-end-pos #f(0 0 -170))
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :wait-interpolation)

  ;;かかる参照力の設定
  ;;インピーダンス制御を入れている場合、設定した反力を受けるまで力をかけるようになる。
  ;;まずは挟む力をかける
  (send *ri* :set-ref-forces
        (list
         (float-vector 0 0 0) ;;rleg
         (float-vector 0 0 0) ;;lleg
         (float-vector 0 -100  0) ;;rarm (x, y, z) 単位はニュートン
         (float-vector 0 100   0) ;;larm
         )
        2000)

  ;;上に持ち上げる力をかける
  (send *ri* :set-ref-forces
        (list
         (float-vector 0 0 0)
         (float-vector 0 0 0)
         (float-vector 0 -100 -5) ;;rarm
         (float-vector 0 100  -5) ;;larm
         )
        3000)
  (unix:sleep 2)

  ;;箱を持ち上げる
  (send *robot* :arms :move-end-pos #f(0 0 200) :world) ;;worldをつけることで世界座標系で手先の移動量を指定
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :wait-interpolation)  
  )

(defun hold-box()
  (movearms 200 0 0)
  (sand-box)
  )

(defun release-box(&optional (y 300))
    (send *ri* :set-ref-forces
        (list
         (float-vector 0 0 0) ;;rleg
         (float-vector 0 0 0) ;;lleg
         (float-vector 0 0 0) ;;rarm (x, y, z) 単位はニュートン
         (float-vector 0 0 0) ;;larm
         )
        2000)
  (send *robot* :arms :move-end-pos (float-vector 0 0 y))
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :wait-interpolation)
  )

;;箱を置く
(defun put-box()
  (send *robot* :arms :move-end-pos #f(0 0 -150) :world)
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :wait-interpolation)
  (release-box)
  )
