(defun calc-toe-heel-phase-ratio
  (toe-angle heel-angle double-support-ratio-half)
  (let* ((remain-ratio (- 1 (* 2 double-support-ratio-half)))
         (total-angle (+ (* toe-angle 2.0) (* heel-angle 2.0)))
         (ret
          (list double-support-ratio-half
                (* remain-ratio (/ toe-angle total-angle))
                (* remain-ratio (/ toe-angle total-angle))
                0
                (* remain-ratio (/ heel-angle total-angle))
                (* remain-ratio (/ heel-angle total-angle))
                double-support-ratio-half)))
    (concatenate float-vector ret)
    ))

(defun set-toe-param (&key (toe-angle 4) (heel-angle 4))
  (send *ri* :set-gait-generator-param
        :toe-angle toe-angle :heel-angle heel-angle
        :use-toe-joint nil
        :use-toe-heel-transition t
        :use-toe-heel-auto-set t
        :toe-heel-phase-ratio (calc-toe-heel-phase-ratio toe-angle heel-angle 0.05)))

(defun setup-params ()
  ;; (load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2jsk-interface.l")
  ;; (hrp2jsk-init)
  (load "package://hrpsys_ros_bridge_tutorials/euslisp/jaxon_red-interface.l")
  (jaxon_red-init)
  (setq *robot* *jaxon_red*)
  (objects (list *robot*))
  ;; セグウェイ
  ;; (setq *step-fwd* 240) ;; 踏み台距離[mm] (HRP2足先からセグウェイまで人間の親指1本分) 2017 Best
  (setq *step-fwd* 250) ;; 踏み台距離[mm] 2018/01/19 Demo Best
  ;; (setq *step-fwd* 270) ;; 踏み台距離[mm]
  ;; (setq *step-fwd* 280) ;; 踏み台距離[mm]
  (setq *step-height* 0) ;; 踏み台高さ[mm]
  (setq *feet-width-half-offset* 52.5) ;; 乗り込み姿勢での足幅オフセット分の半分[mm]
  ;; ;; キャスター
  ;; (setq *step-fwd* 280) ;; 踏み台距離[mm]
  ;; (setq *step-height* 82) ;; 踏み台高さ[mm]
  ;; (setq *feet-width-half-offset* 12.5) ;; 乗り込み姿勢での足幅オフセット分の半分[mm]
  (send *robot* :reset-manip-pose)
  (send *robot* :head-neck-p :joint-angle -10)
  (send *robot* :fix-leg-to-coords (make-coords))
  (send *robot* :move-centroid-on-foot :both '(:rleg :lleg))
  (setq *av0* (send *robot* :angle-vector))
  (send *robot* :reset-manip-pose)
  (send *robot* :head-neck-p :joint-angle -10)
  (send *robot* :fix-leg-to-coords (make-coords))
  ;;(send *robot* :legs :move-end-pos (float-vector 0 0 *step-height*))
  ;; (send *robot* :legs :move-end-pos (float-vector 0 0 65)) ;; 腰高さ調節[mm] (2017/11/5 腰下げすぎると乗り込み時のlleg-knee-p負荷で落ちる)
  ;; (send *robot* :legs :move-end-pos (float-vector 0 0 55)) ;; 腰高さ調節[mm] (2017/11/7 Best ごくたまに1/10くらいの確率でlleg-knee-p負荷で落ちる＝＞学習時はこれが安定している)
  (send *robot* :legs :move-end-pos (float-vector 0 0 50)) ;; 腰高さ調節[mm] (2017/11/7 上記よりは負荷落ちしにくくはなるが，rlegが伸びきり気味？＝＞学習時には不向き)
  ;; (send *robot* :legs :move-end-pos (float-vector 0 0 45)) ;; 腰高さ調節[mm] (2017/11/24 test)
  (send *robot* :move-centroid-on-foot :both '(:rleg :lleg))
  (setq *av1* (send *robot* :angle-vector))
  ;;
  (send *robot* :angle-vector *av0*)
  (send *irtviewer* :draw-objects)
)

(defun setup (&key (use-toe-p ))
  (setup-params)
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (send *ri* :start-auto-balancer :limbs '(:rleg :lleg))
  (send *ri* :start-st)
  (send *ri* :set-gait-generator-param
        :default-orbit-type :stair
        :default-step-time 1.5)
  ;; ;;;; 空中で試す場合は以下のパラメータ（無負荷の空中だと，default-step-timeが短いと関節速度リミットをoverしてcが落ちるため）
  ;; (send *ri* :set-gait-generator-param
  ;;       :default-orbit-type :stair
  ;;       :default-step-time 2.5)
  (if use-toe-p (set-toe-param :toe-angle 20 :heel-angle 5))
  )

(defun setup-segway2 (&key (use-toe-p ))
  (load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2jsk-interface.l")
  (hrp2jsk-init)
  (setq *robot* *hrp2jsk*)
  (objects (list *robot*))
  ;; セグウェイ2
  ;; (setq *step-fwd* 240) ;; 踏み台距離[mm] (HRP2足先からセグウェイまで人間の親指1本分) 2017 Best
  (setq *step-fwd* (+ 250 60 20)) ;; 踏み台距離[mm] (2019/01/19 親指2つ分バージョン)
  ;; (setq *step-fwd* 270) ;; 踏み台距離[mm]
  ;; (setq *step-fwd* 280) ;; 踏み台距離[mm]
  (setq *step-height* 120) ;; 踏み台高さ[mm]
  (setq *feet-width-half-offset* 0) ;; 乗り込み姿勢での足幅オフセット分の半分[mm]
  ;; ;; キャスター
  ;; (setq *step-fwd* 280) ;; 踏み台距離[mm]
  ;; (setq *step-height* 82) ;; 踏み台高さ[mm]
  ;; (setq *feet-width-half-offset* 12.5) ;; 乗り込み姿勢での足幅オフセット分の半分[mm]
  (send *robot* :reset-manip-pose)
  (send *robot* :head-neck-p :joint-angle -10)
  (send *robot* :rleg :move-end-pos #f(0 -50 0) :local)
  (send *robot* :lleg :move-end-pos #f(0 50 0) :local)
  (send *robot* :fix-leg-to-coords (make-coords))
  (send *robot* :move-centroid-on-foot :both '(:rleg :lleg))
  (setq *av0-segway2* (send *robot* :angle-vector))
  (send *robot* :angle-vector *av0-segway2*)
  ;;;; (send *robot* :legs :move-end-pos (float-vector 0 0 55)) ;; 腰高さ調節[mm] (2017/11/7 Best ごくたまに1/10くらいの確率でlleg-knee-p負荷で落ちる＝＞学習時はこれが安定している)
  (send *robot* :legs :move-end-pos (float-vector 0 0 (+ 70 10))) ;; 腰高さ調節[mm] (2019/01/19 親指2つ分バージョン)
  ;; (send *robot* :legs :move-end-pos (float-vector 0 0 50)) ;; 腰高さ調節[mm] (2017/11/7 上記よりは負荷落ちしにくくはなるが，rlegが伸びきり気味？＝＞学習時には不向き)
  ;; (send *robot* :legs :move-end-pos (float-vector 0 0 45)) ;; 腰高さ調節[mm] (2017/11/24 test)
  (send *robot* :move-centroid-on-foot :both '(:rleg :lleg))
  (setq *av1-segway2* (send *robot* :angle-vector))
  ;;
  (send *robot* :angle-vector *av0-segway2*)
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;; (send *ri* :start-auto-balancer)
  (send *ri* :start-auto-balancer :limbs '(:rleg :lleg))
  (send *ri* :start-st)
  (send *ri* :set-gait-generator-param
        :default-orbit-type :stair
        :default-step-time 1.5)
  (if use-toe-p (set-toe-param :toe-angle 20 :heel-angle 5))
  )

(defun setup-skate (&key (use-toe-p ))
  (load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2jsk-interface.l")
  (hrp2jsk-init)
  (setq *robot* *hrp2jsk*)
  (objects (list *robot*))
  ;; スケート
  ;; (setq *step-fwd* 240) ;; 踏み台距離[mm] (HRP2足先からセグウェイまで人間の親指1本分) 2017 Best
  (setq *step-fwd* (+ 250 60 20)) ;; 踏み台距離[mm] (2019/11/11 親指2つ分空ける)
  ;; (setq *step-fwd* 250) ;; 踏み台距離[mm] (2019/11/11 親指2つ分空ける)
  ;; (setq *step-fwd* (+ 250 60 20 20)) ;; 踏み台距離[mm] (2019/11/11 親指3つ分空ける)
  ;; (setq *step-fwd* 270) ;; 踏み台距離[mm]
  ;; (setq *step-fwd* 280) ;; 踏み台距離[mm]
  ;; (setq *step-height* 120) ;; 踏み台高さ[mm]
  (setq *step-height* 87) ;; 踏み台高さ[mm]
  (setq *feet-width-half-offset* 0) ;; 乗り込み姿勢での足幅オフセット分の半分[mm]
  ;; ;; キャスター
  ;; (setq *step-fwd* 280) ;; 踏み台距離[mm]
  ;; (setq *step-height* 82) ;; 踏み台高さ[mm]
  ;; (setq *feet-width-half-offset* 12.5) ;; 乗り込み姿勢での足幅オフセット分の半分[mm]
  (send *robot* :reset-manip-pose)
  (send *robot* :head-neck-p :joint-angle -10)
  (send *robot* :rleg :move-end-pos #f(0 -50 0) :local)
  (send *robot* :lleg :move-end-pos #f(0 50 0) :local)
  (send *robot* :fix-leg-to-coords (make-coords))
  (send *robot* :move-centroid-on-foot :both '(:rleg :lleg))
  (setq *av0-skate* (send *robot* :angle-vector))
  (send *robot* :angle-vector *av0-skate*)
  ;;;; (send *robot* :legs :move-end-pos (float-vector 0 0 55)) ;; 腰高さ調節[mm] (2017/11/7 Best ごくたまに1/10くらいの確率でlleg-knee-p負荷で落ちる＝＞学習時はこれが安定している)
  ;; (send *robot* :legs :move-end-pos (float-vector 0 0 (+ 70 10))) ;; 腰高さ調節[mm] (2019/01/19 親指2つ分バージョン)
  (send *robot* :legs :move-end-pos (float-vector 0 0 40)) ;; 腰高さ調節[mm] (2019/11/11)
  ;; (send *robot* :legs :move-end-pos (float-vector 0 0 50)) ;; 腰高さ調節[mm] (2017/11/7 上記よりは負荷落ちしにくくはなるが，rlegが伸びきり気味？＝＞学習時には不向き)
  ;; (send *robot* :legs :move-end-pos (float-vector 0 0 45)) ;; 腰高さ調節[mm] (2017/11/24 test)
  (send *robot* :move-centroid-on-foot :both '(:rleg :lleg))
  (setq *av1-skate* (send *robot* :angle-vector))
  ;;
  (send *robot* :angle-vector *av0-skate*)
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;; (send *ri* :start-auto-balancer)
  (send *ri* :start-auto-balancer :limbs '(:rleg :lleg))
  (send *ri* :start-st)
  (send *ri* :set-gait-generator-param
        :default-orbit-type :stair
        :default-step-time 1.5)
  (if use-toe-p (set-toe-param :toe-angle 20 :heel-angle 5))
  )

(defun setup-ninebot (&key (use-toe-p ))
  (load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2jsk-interface.l")
  (hrp2jsk-init)
  (setq *robot* *hrp2jsk*)
  (objects (list *robot*))
  (send *robot* :reset-manip-pose)
  (send *robot* :head-neck-p :joint-angle -10)
  (send *robot* :rleg :move-end-pos #f(0 -50 0) :local)
  (send *robot* :lleg :move-end-pos #f(0 50 0) :local)
  (send *robot* :fix-leg-to-coords (make-coords))
  (send *robot* :move-centroid-on-foot :both '(:rleg :lleg))
  (setq *av-ninebot* (send *robot* :angle-vector))
  (send *robot* :angle-vector *av-ninebot*)
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (send *ri* :start-auto-balancer)
  (send *ri* :start-st)
  (if use-toe-p (set-toe-param :toe-angle 20 :heel-angle 5))
  )

(defun set-ground-abc-st-param ()
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 10 0) (float-vector 20 -10 0))) ;; 2017/04/02 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 (- 10 15) 0) (float-vector 20 (- -10 15) 0))) ;; 2017/11/24 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 (- 10 10) 0) (float-vector 20 (- -10 10) 0))) ;; 2017/12/18 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 35 (- 10 25) 0) (float-vector 35 (- -10 25) 0))) ;; 2018/01/19 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 20) 0) (float-vector 30 (- -10 20) 0))) ;; 2018/10/16 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 10) 0) (float-vector 30 (- -10 10) 0))) ;; 2019/01/17 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 35 (- 10 10) 0) (float-vector 35 (- -10 10) 0))) ;; 2019/01/19 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 35 (- 10 15) 0) (float-vector 35 (- -10 15) 0))) ;; 2019/04/12 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 40 (- 10 15) 0) (float-vector 40 (- -10 15) 0))) ;; 2019/04/13 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 40 (- 10 10) 0) (float-vector 40 (- -10 10) 0))) ;; 2019/05/13 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 40 (- 10 5) 0) (float-vector 40 (- -10 5) 0))) ;; 2019/07/12 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 45 (- 10 10) 0) (float-vector 45 (- -10 10) 0))) ;; 2019/09/10 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 5) (- 10 35) 0) (float-vector (+ 10 5) (- -10 35) 0))) ;; 2019/11/02 Demo Best (After ankle roll limit-pin adjustment)
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 5) (- 10 30) 0) (float-vector (+ 10 5) (- -10 30) 0))) ;; 2019/11/05 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 25) (- 10 30) 0) (float-vector (+ 10 25) (- -10 30) 0))) ;; 2020/02/06 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 30) (- 10 25) 0) (float-vector (+ 10 30) (- -10 25) 0))) ;; 2020/03/25 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 25) (- 10 30) 0) (float-vector (+ 10 25) (- -10 30) 0))) ;; 2020/03/26 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 15) 10 0) (float-vector (+ 10 15) -10 0))) ;; 2020/08/06 Demo Best (after fixing calib.dat) => fall backward when riding off
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 25) 10 0) (float-vector (+ 10 25) -10 0))) ;; 2020/08/06 Demo Best (after fixing calib.dat)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 -10) 10 0) (float-vector (+ 10 -10) -10 0))) ;; 2021/08/18 (old ZBOX + ZED -> new Jetson + Zed mini)
  (send *ri* :set-st-param
        ;; :eefm-k1 #f(-1.27286 -1.27286) ;; walking default
        ;; :eefm-k2 #f(-0.363674 -0.363674) ;; walking default
        ;; :eefm-k3 #f(-0.162 -0.162) ;; walking default
        ;; :eefm-rot-damping-gain (list (float-vector 22.0 22.0 100000.0) ;; walking default
        ;;                              (float-vector 22.0 22.0 100000.0) ;; walking default
        ;;                              (float-vector 22.0 22.0 100000.0)
        ;;                              (float-vector 22.0 22.0 100000.0))
        :segway-av-yaw-pgain 0.0 :segway-av-yaw-igain 0.0 :segway-av-yaw-dgain 0.0
        :segway-lv-x-pgain 0.0 :segway-lv-x-igain 0.0 :segway-lv-x-dgain 0.0
        :segway-ride-mode nil
        :segway-learning-mode-after-ride nil
        :segway-learning-mode-during-ride nil
        :emergency-check-mode 0))

(defun set-ground-abc-st-param-segway2 ()
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 10 0) (float-vector 20 -10 0))) ;; 2017/04/02 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 (- 10 15) 0) (float-vector 20 (- -10 15) 0))) ;; 2017/11/24 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 (- 10 10) 0) (float-vector 20 (- -10 10) 0))) ;; 2017/12/18 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 35 (- 10 25) 0) (float-vector 35 (- -10 25) 0))) ;; 2018/01/19 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 20) 0) (float-vector 30 (- -10 20) 0))) ;; 2018/10/16 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 10) 0) (float-vector 30 (- -10 10) 0))) ;; 2019/01/17 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 10) 0) (float-vector 30 (- -10 10) 0))) ;; 2019/01/19 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 5) (- 10 30) 0) (float-vector (+ 10 5) (- -10 30) 0))) ;; 2019/11/10 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 10) (- 10 30) 0) (float-vector (+ 10 10) (+ (- -10 30) 20) 0))) ;; 2019/11/10 Demo Best (第1ステップである左足のdzoのy成分を調整することで，segway2がRollまわりに傾いて転倒するのを防止できる), ロボット足部とsegway2間は親指2本分
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 10) (- 10 30) 0) (float-vector (+ 10 10) (+ (- -10 30) 30) 0))) ;; 2019/11/15 Demo Best
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 10) (- 10 30) 0) (float-vector (+ 10 10) (+ (- -10 30) 25) 0))) ;; 2019/11/15 Demo Best
  (send *ri* :set-st-param
        :eefm-k1 #f(-1.27286 -1.27286) ;; walking default
        :eefm-k2 #f(-0.363674 -0.363674) ;; walking default
        :eefm-k3 #f(-0.162 -0.162) ;; walking default
        :eefm-rot-damping-gain (list (float-vector 22.0 22.0 100000.0) ;; walking default
                                     (float-vector 22.0 22.0 100000.0) ;; walking default
                                     (float-vector 22.0 22.0 100000.0)
                                     (float-vector 22.0 22.0 100000.0))
        :segway-av-yaw-pgain 0.0 :segway-av-yaw-igain 0.0 :segway-av-yaw-dgain 0.0
        :segway-lv-x-pgain 0.0 :segway-lv-x-igain 0.0 :segway-lv-x-dgain 0.0
        :segway2-ride-mode nil
        :emergency-check-mode 0))

(defun set-ground-abc-st-param-skate ()
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 10 0) (float-vector 20 -10 0))) ;; 2017/04/02 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 (- 10 15) 0) (float-vector 20 (- -10 15) 0))) ;; 2017/11/24 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 (- 10 10) 0) (float-vector 20 (- -10 10) 0))) ;; 2017/12/18 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 35 (- 10 25) 0) (float-vector 35 (- -10 25) 0))) ;; 2018/01/19 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 20) 0) (float-vector 30 (- -10 20) 0))) ;; 2018/10/16 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 10) 0) (float-vector 30 (- -10 10) 0))) ;; 2019/01/17 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 10) 0) (float-vector 30 (- -10 10) 0))) ;; 2019/01/19 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 5) (- 10 30) 0) (float-vector (+ 10 5) (- -10 30) 0))) ;; 2019/11/10 Demo Best
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 10) (- 10 30) 0) (float-vector (+ 10 10) (+ (- -10 30) 20) 0))) ;; 2019/11/11 Demo Best
  (send *ri* :set-st-param
        :eefm-k1 #f(-1.27286 -1.27286) ;; walking default
        :eefm-k2 #f(-0.363674 -0.363674) ;; walking default
        :eefm-k3 #f(-0.162 -0.162) ;; walking default
        :eefm-rot-damping-gain (list (float-vector 22.0 22.0 100000.0) ;; walking default
                                     (float-vector 22.0 22.0 100000.0) ;; walking default
                                     (float-vector 22.0 22.0 100000.0)
                                     (float-vector 22.0 22.0 100000.0))
        :segway-av-yaw-pgain 0.0 :segway-av-yaw-igain 0.0 :segway-av-yaw-dgain 0.0
        :segway-lv-x-pgain 0.0 :segway-lv-x-igain 0.0 :segway-lv-x-dgain 0.0
        :segway-ride-mode nil :segway2-ride-mode nil
        :emergency-check-mode 0))

(defun set-segway-abc-st-param ()
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 10 0) (float-vector 20 -10 0))) ;; 2017/04/02 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 (- 10 15) 0) (float-vector 20 (- -10 15) 0))) ;; 2017/11/24 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 40 (- 10 10) 0) (float-vector 40 (- -10 10) 0))) ;; 2019/05/13 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 40 (- 10 5) 0) (float-vector 40 (- -10 5) 0))) ;; 2019/07/12 Demo Best
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 -10) 10 0) (float-vector (+ 10 -10) -10 0))) ;; 2021/08/18 (old ZBOX + ZED -> new Jetson + Zed mini)
  (send *ri* :set-st-param
        ;; :eefm-k1 #f(-1.41607 -1.41607)
        ;; :eefm-k2 #f(-0.406177 -0.406177)
        ;; :eefm-k3 #f(-0.180547 -0.180547)
        ;; :eefm-rot-damping-gain (list (float-vector (* 4 22.0) (* 4 22.0) 100000.0)
        ;;                              (float-vector (* 4 22.0) (* 4 22.0) 100000.0)
        ;;                              (float-vector 22.0 22.0 100000.0)
        ;;                              (float-vector 22.0 22.0 100000.0))
        ;; :eefm-rot-damping-gain (list (float-vector 22.0 (* 4 22.0) 100000.0)
        ;;                              (float-vector 22.0 (* 4 22.0) 100000.0)
        ;;                              (float-vector 22.0 22.0 100000.0)
        ;;                              (float-vector 22.0 22.0 100000.0))
        :segway-av-yaw-pgain 0.00045 :segway-av-yaw-igain 0.00045 :segway-av-yaw-dgain 0.00003
        ;; :segway-av-yaw-pgain 0.0 :segway-av-yaw-igain 0.0 :segway-av-yaw-dgain 0.0
        :segway-lv-x-pgain 0.004 :segway-lv-x-igain 0.001 :segway-lv-x-dgain 0.0001
        :segway-ride-mode nil
        :emergency-check-mode 0))

(defun set-segway2-abc-st-param ()
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 10 0) (float-vector 20 -10 0))) ;; 2017/04/02 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 (- 10 15) 0) (float-vector 20 (- -10 15) 0))) ;; 2017/11/24 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 20 (- 10 10) 0) (float-vector 20 (- -10 10) 0))) ;; 2017/12/18 best tuning
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 35 (- 10 25) 0) (float-vector 35 (- -10 25) 0))) ;; 2018/01/19 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 20) 0) (float-vector 30 (- -10 20) 0))) ;; 2018/10/16 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 10) 0) (float-vector 30 (- -10 10) 0))) ;; 2019/01/17 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 10) 0) (float-vector 30 (- -10 10) 0))) ;; 2019/01/19 Demo Best
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 5) (- 10 30) 0) (float-vector (+ 10 5) (- -10 30) 0))) ;; 2019/11/10 Demo Best
  ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector (+ 10 10) (- 10 30) 0) (float-vector (+ 10 10) (+ (- -10 30) 20) 0))) ;; 2019/11/10 Demo Best
  (send *ri* :set-st-param
        :eefm-k1 #f(-1.41607 -1.41607)
        :eefm-k2 #f(-0.406177 -0.406177)
        :eefm-k3 #f(-0.180547 -0.180547)
        :eefm-rot-damping-gain (list (float-vector (* 8 22.0) (* 40 22.0) 100000.0)
                                     (float-vector (* 8 22.0) (* 40 22.0) 100000.0)
                                     (float-vector 22.0 22.0 100000.0)
                                     (float-vector 22.0 22.0 100000.0))
        :segway-av-yaw-pgain 0.0015 :segway-av-yaw-igain 0.0 :segway-av-yaw-dgain 0.0001
        :segway-lv-x-pgain 0.0015 :segway-lv-x-igain 0.0001 :segway-lv-x-dgain 0.0001
        :segway2-ride-mode nil
        :emergency-check-mode 0))

(defun set-ninebot-abc-st-param ()
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 30 (- 10 10) 0) (float-vector 30 (- -10 10) 0)))
  (send *ri* :set-st-param
        :eefm-k1 #f(-1.41607 -1.41607)
        :eefm-k2 #f(-0.406177 -0.406177)
        :eefm-k3 #f(-0.180547 -0.180547)
        :eefm-rot-damping-gain (list (float-vector (* 8 22.0) (* 10 22.0) 100000.0)
                                     (float-vector (* 8 22.0) (* 10 22.0) 100000.0)
                                     (float-vector 22.0 22.0 100000.0)
                                     (float-vector 22.0 22.0 100000.0))
        :segway-av-yaw-pgain 0.0 :segway-av-yaw-igain 0.0 :segway-av-yaw-dgain 0.0
        :segway-lv-x-pgain 0.0 :segway-lv-x-igain 0.0 :segway-lv-x-dgain 0.0
        :ninebot-lv-x-pgain 0.4 :ninebot-lv-x-igain 0.1 :ninebot-lv-x-dgain 0.01
        :segway-ride-mode nil
        :segway2-ride-mode nil
        :emergency-check-mode 0
        :eefm-use-force-difference-control t ;; default
        ))

(defun set-learning-param (&key (after-ride ) (during-ride ))
  (when after-ride
    (send *ri* :set-st-param
          :segway-learning-mode nil :segway-learning-mode-lv-x nil
          :segway-learning-rate-pid #f(1.000000e-09 1.000000e-09 1.000000e-10)
          ;; :segway-learning-rate-pid-lv-x #f(4.000000e-07 4.000000e-07 1.000000e-07)
          ;; :segway-learning-rate-pid-lv-x #f(2.000000e-07 2.000000e-07 1.000000e-07)
          ;; :segway-learning-rate-pid-lv-x #f(1.000000e-07 1.000000e-07 1.000000e-07)
          :segway-learning-rate-pid-lv-x #f(1.000000e-07 1.000000e-07 1.000000e-08)
          :segway-learning-mode-after-ride t
          ))
  (when during-ride
    (send *ri* :set-st-param :segway-learning-mode-during-ride t))
  )

(defun riding-demo ()
  (let ((default-step-time (* 1e3 (send (send *ri* :get-gait-generator-param) :default_step_time))))
    (send *ri* :set-foot-steps-with-base-height
          (list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
                (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* *feet-width-half-offset* *step-height*)) :name :lleg)
                (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* (- *feet-width-half-offset*) *step-height*)) :name :rleg))
          (list *av0* *av1* *av0*)
          (list default-step-time default-step-time default-step-time)))
  )

;; (defun riding-demo-off ()
;;   (let ((default-step-time (* 1e3 (send (send *ri* :get-gait-generator-param) :default_step_time))))
;;     (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 25 (- 10 15) 0) (float-vector 25 (- -10 15) 0))) ;; 2019/04/12 Demo Best
;;     (unix:sleep 1)
;;     (send *ri* :set-st-param
;;           :segway-av-yaw-pgain 0.0 :segway-av-yaw-igain 0.0 :segway-av-yaw-dgain 0.0
;;           :segway-lv-x-pgain 0.0 :segway-lv-x-igain 0.0 :segway-lv-x-dgain 0.0
;;           :segway-ride-mode nil
;;           :emergency-check-mode 0)

;;         ;; :eefm-k1 #f(-1.27286 -1.27286) ;; walking default
;;         ;; :eefm-k2 #f(-0.363674 -0.363674) ;; walking default
;;         ;; :eefm-k3 #f(-0.162 -0.162) ;; walking default
;;         ;; :eefm-rot-damping-gain (list (float-vector 22.0 22.0 100000.0) ;; walking default
;;         ;;                              (float-vector 22.0 22.0 100000.0) ;; walking default
;;         ;;                              (float-vector 22.0 22.0 100000.0)
;;         ;;                              (float-vector 22.0 22.0 100000.0))

;;     (send *ri* :set-foot-steps-with-base-height
;;           (list (make-coords :coords (send *robot* :lleg :end-coords :copy-worldcoords) :name :lleg)
;;                 (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector (- *step-fwd*) *feet-width-half-offset* (- *step-height*))) :name :rleg)
;;                 (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector (- *step-fwd*) *feet-width-half-offset* (- *step-height*))) :name :lleg))
;;           (list *av0* *av1* *av0*)
;;           (list default-step-time default-step-time default-step-time))
;;     )
;;   )

(defun riding-demo-off ()
  (let ((default-step-time (* 1e3 (send (send *ri* :get-gait-generator-param) :default_step_time))))
    ;; (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 25 (- 10 15) 0) (float-vector 25 (- -10 15) 0))) ;; 2019/04/12 Demo Best
    ;; (unix:sleep 1)
    (send *ri* :set-st-param
          :segway-av-yaw-pgain 0.0 :segway-av-yaw-igain 0.0 :segway-av-yaw-dgain 0.0
          :segway-lv-x-pgain 0.0 :segway-lv-x-igain 0.0 :segway-lv-x-dgain 0.0
          :segway-ride-mode nil
          :emergency-check-mode 0)

        ;; :eefm-k1 #f(-1.27286 -1.27286) ;; walking default
        ;; :eefm-k2 #f(-0.363674 -0.363674) ;; walking default
        ;; :eefm-k3 #f(-0.162 -0.162) ;; walking default
        ;; :eefm-rot-damping-gain (list (float-vector 22.0 22.0 100000.0) ;; walking default
        ;;                              (float-vector 22.0 22.0 100000.0) ;; walking default
        ;;                              (float-vector 22.0 22.0 100000.0)
        ;;                              (float-vector 22.0 22.0 100000.0))

    ;; (send *ri* :set-foot-steps-with-base-height
    ;;       (list (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* *feet-width-half-offset* *step-height*)) :name :lleg)
    ;;             (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
    ;;             (make-coords :coords (send *robot* :lleg :end-coords :copy-worldcoords) :name :lleg))
    ;;       (list *av0* *av1* *av0*)
    ;;       (list default-step-time default-step-time default-step-time))
    (send *ri* :set-foot-steps-with-base-height
          (list (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* *feet-width-half-offset* *step-height*)) :name :lleg)
                (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 0 (- *feet-width-half-offset*) 0)) :name :rleg)
                (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 0 *feet-width-half-offset* 0)) :name :lleg))
          (list *av0* *av1* *av0*)
          (list default-step-time default-step-time default-step-time))
    )
  )

(defun initialize-foot-width-on-ground ()
  (let ((default-step-time (* 1e3 (send (send *ri* :get-gait-generator-param) :default_step_time))))
    (send *ri* :set-foot-steps-with-base-height
          (list (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 0 (- *feet-width-half-offset*) 0)) :name :rleg)
                (make-coords :coords (send *robot* :lleg :end-coords :copy-worldcoords) :name :lleg)
                (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg))
          (list *av0* *av0* *av0*)
          (list default-step-time default-step-time default-step-time))
    )
  )

(defun riding-demo-retry ()
  (let ((default-step-time (* 1e3 (send (send *ri* :get-gait-generator-param) :default_step_time))))
    (send *ri* :set-foot-steps-with-base-height
          ;; (list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
          ;;       (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* *feet-width-half-offset* *step-height*)) :name :lleg)
          ;;       (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* (- *feet-width-half-offset*) *step-height*)) :name :rleg))
          (list (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 0 (- *feet-width-half-offset*) 0)) :name :rleg)
                (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* *feet-width-half-offset* *step-height*)) :name :lleg)
                (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* (- *feet-width-half-offset*) *step-height*)) :name :rleg))
          (list *av0* *av1* *av0*)
          (list default-step-time default-step-time default-step-time)))
  )

(defun riding-demo-segway2 ()
  (let ((default-step-time (* 1e3 (send (send *ri* :get-gait-generator-param) :default_step_time))))
    (send *ri* :set-foot-steps-with-base-height
          (list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
                (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* *feet-width-half-offset* *step-height*)) :name :lleg)
                ;; (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* (- *feet-width-half-offset*) *step-height*)) :name :rleg))
                ;; (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector (- *step-fwd* 80) (- *feet-width-half-offset*) *step-height*)) :rotate (deg2rad 25) :z :world) :name :rleg))
                ;; (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector (- *step-fwd* 40) (- *feet-width-half-offset*) *step-height*)) :rotate (deg2rad 25) :z :world) :name :rleg))
                (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector (- *step-fwd* 40) (+ (- *feet-width-half-offset*) 30) *step-height*)) :rotate (deg2rad 25) :z :world) :name :rleg))
          (list *av0-segway2* *av1-segway2* *av0-segway2*)
          (list default-step-time default-step-time default-step-time)))
  )

(defun riding-demo-skate ()
  (let ((default-step-time (* 1e3 (send (send *ri* :get-gait-generator-param) :default_step_time))))
    (send *ri* :set-foot-steps-with-base-height
          (list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
                (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* *feet-width-half-offset* *step-height*)) :name :lleg)
                (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector *step-fwd* (- *feet-width-half-offset*) *step-height*)) :name :rleg))
                ;; (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector (- *step-fwd* 50) (- *feet-width-half-offset*) *step-height*)) :name :rleg))
          (list *av0-skate* *av1-skate* *av0-skate*)
          (list default-step-time default-step-time default-step-time)))
  )

(warn "~%~%")
(warn ";;;;;;;;;; Caution! : Please use LiFe battery in this experiment !!! ;;;;;;;;;;~%")
(warn ";;;;;;;;;; Please check /joy and /zed/odom ;;;;;;;;;;~%~%")
(warn ";; (setup)~%")
(warn ";; (set-ground-abc-st-param)~%")
(warn ";;;; If learning~%")
(warn ";; (set-learning-param :after-ride t :during-ride nil)~%")
(warn ";; (set-learning-param :after-ride nil :during-ride t)~%")
(warn ";; (set-learning-param :after-ride t :during-ride t)~%")
(warn ";;;; After landing robot~%")
(warn ";; (send *ri* :set-st-param :segway-ride-mode t)~%")
(warn ";;;; Power on segway and Put segway in front of robot (The distance between segway and robot is about the thickness of human thumb)~%")
(warn ";; (progn (unix:sleep 8) (riding-demo)) ;;;; Start riding into segway after 8[s]~%")

#|
# Hrpsys simulatorの起動（セグウェイの場合）

openhrp-project-generator `rospack find hrp2_models`/HRP2JSK_for_OpenHRP3/HRP2JSKmain_bush.wrl `rospack find openhrp3`/sample/model/longfloor.wrl `rospack find openhrp3`/sample/model/box.wrl,0.26,0,0.015,1,0,0,0 --use-highgain-mode false --output /tmp/HRP2JSK_for_torquecontrol.xml --timeStep 0.001 --dt 0.004 --method RUNGE_KUTTA
export BUSH_CUSTOMIZER_CONFIG_PATH=`rospack find hrpsys_ros_bridge_tutorials`/models/HRP2JSK_bush_customizer_param.conf
rtmlaunch hrpsys_ros_bridge_tutorials hrp2jsk.launch PROJECT_FILE:=/tmp/HRP2JSK_for_torquecontrol.xml hrpsys_precreate_rtc:=PDcontroller RUN_RVIZ:=false


# Hrpsys simulatorの起動（キャスター台車の場合）

openhrp-project-generator `rospack find hrp2_models`/HRP2JSK_for_OpenHRP3/HRP2JSKmain_bush.wrl `rospack find openhrp3`/sample/model/longfloor.wrl `rospack find openhrp3`/sample/model/box.wrl,0.26,0,-0.018,1,0,0,0 --use-highgain-mode false --output /tmp/HRP2JSK_for_torquecontrol.xml --timeStep 0.001 --dt 0.004 --method RUNGE_KUTTA
同上
同上
|#
