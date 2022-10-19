(load "package://push-recovery/push-recovery-foot-guided.l")
(robots-init "jaxon_red")
(start-footguided-modification)

(send *ri* :set-gait-generator-param
           :modify-footsteps nil       ;;着地位置補正を行うと、着地位置がずれてしまうので、環境認識を行わない場合は切る
           :default-step-height 0.1   ;;足上げ高さ
           :default-step-time 1.5      ;;歩行速度
           :default-double-support-ratio 0.4) ;;両足支持期間の割合
  
(defun reset-param()
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 0 20 0) (float-vector 0 -20 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *robot* :reset-pose)
  (send *ri* :angle-vector (send *robot* :angle-vector))
  )

(defun go-stair(&optional (w 450) (h 200) (dx 0))
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 20 0) (float-vector dx -20 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :name :lleg)
	      (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :name :rleg)
	      )
	)
  )

(defun flat-to-stair-toe(&optional (w 270) (h 200) (dx 20))
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 20 0) (float-vector dx -20 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad -20) :y) :name :lleg) 
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad -20) :y) :name :rleg)
	      )
	)
  )



(defun stair-to-stair-toe(&optional (w 320) (h 200) (dx 24))
  (send *robot* :legs :crotch-p :joint-angle -40)
  (send *ri* :angle-vector (send *robot* :angle-vector) 500)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx -0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :wait-interpolation)
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send (send *robot* :lleg :end-coords :copy-worldcoords):rotate (deg2rad 20) :y) :translate (float-vector w 0 h)):rotate (deg2rad -20) :y) :name :lleg)
	      (make-coords :coords (send (send (send (send *robot* :rleg :end-coords :copy-worldcoords):rotate (deg2rad 20) :y) :translate (float-vector w 0 h)):rotate (deg2rad -20) :y) :name :rleg)
	      
	      )
	)
  )

(defun stair-toe-to-flat(&optional (w 200) (h 50) (dx 20))
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx 0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :rotate (deg2rad 20) :y) :translate (float-vector w 0 h)) :name :lleg)
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :rotate (deg2rad 20) :y) :translate (float-vector w 0 h)) :name :rleg)
	      )
	)
  )

(defun down-flat-to-stair-toe(&optional (w 160) (h -50) (dx -20))
  (lower-waist 200)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 20 0) (float-vector dx -20 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :lleg)
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :rleg)
	      )
	)
  )

(defun down-stair-to-stair-toe(&optional (w 275) (h -200) (dx -30))
					;(send *robot* :legs :crotch-p :joint-angle -40)
  (lower-waist 200)
  (send *ri* :angle-vector (send *robot* :angle-vector) 500)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx -0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :wait-interpolation)
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send (send *robot* :lleg :end-coords :copy-worldcoords):rotate (deg2rad -20) :y) :translate (float-vector w 0 h)):rotate (deg2rad 20) :y) :name :lleg)
	      (make-coords :coords (send (send (send (send *robot* :rleg :end-coords :copy-worldcoords):rotate (deg2rad -20) :y) :translate (float-vector w 0 h)):rotate (deg2rad 20) :y) :name :rleg)
	      
	      )
	)
  )

(defun down-stair-toe-to-flat(&optional (w 275) (h -200) (dx -30))
					;(send *robot* :legs :crotch-p :joint-angle -40)
  (lower-waist 200)
  (send *ri* :angle-vector (send *robot* :angle-vector) 500)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx -0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :wait-interpolation)
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords):rotate (deg2rad -20) :y) :translate (float-vector w 0 h)) :name :lleg)
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords):rotate (deg2rad -20) :y) :translate (float-vector w 0 h)) :name :rleg)
	      
	      )
	)
  )

(defun down-stair-easy()
  (down-flat-to-stair-toe 140)
  (down-stair-toe-to-flat)
  )

(defun up-stair-demo()  
  (go-stair)
  (go-stair)
  (flat-to-stair-toe)
  (stair-to-stair-toe)
  (stair-to-stair-toe)
  (stair-toe-to-flat)
  (reset-param)
  )

(defun down-stair-demo()
  (reset-param)
  (down-flat-to-stair-toe)
  (down-stair-to-stair-toe)
  (down-stair-to-stair-toe)
  (down-stair-toe-to-flat)
  ;(go-stair 400 -200 0)
  (down-stair-easy)
  (down-stair-easy)
  (reset-param)
  )
  

(defun stair-demo()
  (lower-waist)
  (send *ri* :go-pos 0.8 0 0)
  (up-stair-demo)
  (send *ri* :go-pos 0.2 0 180)
  (send *ri* :go-pos 0.18 0 0)
  (down-stair-demo)
  (send *ri* :go-pos 0.785 0 0)
  (send *ri* :go-pos 0 0 180.2)
  )

(defun stair-loop()
  (setq i 0)
  (do-until-key
   (stair-demo)
   (print i)
   (setq i (+ i 1)))
