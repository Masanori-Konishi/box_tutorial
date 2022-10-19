3(load "package://push-recovery/push-recovery-foot-guided.l")
(robots-init "jaxon_red")
(start-footguided-modification)

(send *ri* :set-gait-generator-param
           :modify-footsteps nil       ;;着地位置補正を行うと、着地位置がずれてしまうので、環境認識を行わない場合は切る
           :default-step-height 0.1   ;;足上げ高さ
           :default-step-time 1.5      ;;歩行速度
           :default-double-support-ratio 0.4) ;;両足支持期間の割合

(lower-waist) ;;腰を下げる

;(send *ri* :go-pos 1.5 0 0) ;;段差の前まで進む

(defun setv(&optional (v 1.5) (h 0.1))
  (send *ri* :set-gait-generator-param
           :modify-footsteps nil       ;;着地位置補正を行うと、着地位置がずれてしまうので、環境認識を行わない場合は切る
           :default-step-height h   ;;足上げ高さ
           :default-step-time v      ;;歩行速度
           :default-double-support-ratio 0.4) ;;両足支持期間の割合
  )
  
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



(defun down-flat-to-stair-toe(&optional (w 160) (h -50) (dx -20))
  (lower-waist 100)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 20 0) (float-vector dx -20 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :lleg)
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :rleg)
	      )
	)
  )

(defun stair-to-stair-toe(&optional (w 315) (h 250) (dx 24) (hz 0))
  (send *robot* :legs :crotch-p :joint-angle -40)
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx -0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :wait-interpolation)
  (setq c (sqrt (+(* w w)(* h h))))
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector c 0 hz)) :name :lleg)
	      (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector c 0 hz)) :name :rleg)
	      )
	)
  )

(defun stair-to-stair-toe2(&optional (w 320) (h 200) (dx 24))
  (send *robot* :legs :crotch-p :joint-angle -40)
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx -0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :wait-interpolation)
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send (send *robot* :lleg :end-coords :copy-worldcoords):rotate (deg2rad 20) :y) :translate (float-vector w 0 h)):rotate (deg2rad -20) :y) :name :lleg)
	      (make-coords :coords (send (send (send (send *robot* :rleg :end-coords :copy-worldcoords):rotate (deg2rad 20) :y) :translate (float-vector w 0 h)):rotate (deg2rad -20) :y) :name :rleg)
	      
	      )
	)
  )

(defun down-stair-to-stair-toe2(&optional (w 275) (h -200) (dx -30))
					;(send *robot* :legs :crotch-p :joint-angle -40)
  (lower-waist 200)
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
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
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx -0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :wait-interpolation)
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords):rotate (deg2rad -20) :y) :translate (float-vector w 0 h)) :name :lleg)
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords):rotate (deg2rad -20) :y) :translate (float-vector w 0 h)) :name :rleg)
	      
	      )
	)
  )


(defun stair-toe-to-flat2(&optional (w 200) (h 50) (dx 20))
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx 0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :rotate (deg2rad 20) :y) :translate (float-vector w 0 h)) :name :lleg)
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :rotate (deg2rad 20) :y) :translate (float-vector w 0 h)) :name :rleg)
	      )
	)
  )

(defun down-stair-easy()
  (down-flat-to-stair-toe 140)
  (down-stair-toe-to-flat)
  )


(defun act()
  (send *ri* :go-pos 0.8 0 0)
  (go-stair)
  (go-stair)
  (flat-to-stair-toe)
  ;(setv 0.5 0.2)
  (stair-to-stair-toe2)
  (stair-to-stair-toe2)
  (stair-toe-to-flat2)
  (reset-param)
  (send *ri* :go-pos 0.2 0 180)
  (send *ri* :go-pos 0.18 0 0)
  (reset-param)
  (down-flat-to-stair-toe)
  (down-stair-to-stair-toe2)
  (down-stair-to-stair-toe2)
  (down-stair-toe-to-flat)
  ;(lower-waist 100)
  ;(go-stair 400 -200 0)
  ;(go-stair 400 -200 0)
  (down-stair-easy)
  (down-stair-easy)
  )
