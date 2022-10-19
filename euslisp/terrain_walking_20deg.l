(load "package://push-recovery/push-recovery-foot-guided.l")
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
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 20 0) (float-vector dx -20 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *robot* :reset-pose)
  (send *ri* :angle-vector (send *robot* :angle-vector))
  )

(defun go-stair(&optional (w 450) (h 200))
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

(defun down-flat-to-stair-toe(&optional (w 270) (h -200) (dx 20))
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 20 0) (float-vector dx -20 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :lleg)
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :rleg)
	      )
	)
  )

(defun stair-to-stair-toe(&optional (w 320) (h 250) (dx 24) (hz 0))
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

(defun stair-to-stair-toe2(&optional (w 200) (h 200) (dx 24))
  (send *robot* :legs :crotch-p :joint-angle -40)
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx -0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :wait-interpolation)
  (setq c (sqrt (+(* w w)(* h h))))
  (send *ri* :set-foot-steps
	(list (make-coords :coords ((send *robot* :rleg :end-coords :copy-worldcoords):rotate (deg2rad 20)) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :lleg)
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :rleg)
			   
	      
	      )
	)
  )

(defun stair-toe-to-flat(&optional (w 200) (h 50) (dx 20))
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 0 0) (float-vector dx 0 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
	(list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	      (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :lleg)
	      (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :rotate (deg2rad 20) :y) :name :rleg)
	      )
	)
  )


(defun act()
  (send *ri* :go-pos 0.8 0 0)
  (go-stair)
  (go-stair)
  (flat-to-stair-toe)
  ;(setv 0.5 0.2)
  (stair-to-stair-toe)
  (stair-to-stair-toe)
  (stair-toe-to-flat)
  (reset-param)
  (send *ri* :go-pos 0.2 0 0)
  (send *ri* :go-pos -0.3 0 180)
  (reset-param)
  (down-flat-to-stair-toe)
  )



(defun nokori()
(send *ri* :set-foot-steps
  (list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
        (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 130 0 0  )) :name :lleg)
        (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 130 0 0  )) :name :rleg)
        (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 370 0 100)) :name :lleg)
        (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 370 0 100)) :name :rleg)
        (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 500 0 100)) :name :lleg)
        (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 630 0 100)) :name :rleg)
        (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 870 0 200)) :name :lleg)
        (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 870 0 200)) :name :rleg)
        (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 1000 0 200)) :name :lleg)
        (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 1150 0 200)) :name :rleg)
        (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 1390 0 171)) :rotate (deg2rad -15) :y) :name :lleg)
        (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 1500 0 200)) :rotate (deg2rad -15) :y) :name :rleg)
        (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 1630 0 233)) :rotate (deg2rad -15) :y) :name :lleg)
        (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 1870 0 233)) :rotate (deg2rad 15) :y) :name :rleg)
        (make-coords :coords (send (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 2000 0 200)) :rotate (deg2rad 15) :y) :name :lleg)
        (make-coords :coords (send (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 2130 0 166)) :rotate (deg2rad 15) :y) :name :rleg)
        (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 2370 0 100)) :name :lleg)
        (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 2500 0 100)) :name :rleg)
        (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 2500 0 100)) :name :lleg)
	(make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 2500 0 100)) :name :rleg)

	
	(make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 2600 0 100)) :name :lleg)
	(make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 2600 0 100)) :name :rleg)
	
	;(make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 2850 0 0)) :name :lleg)
	;(make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 2850 0 0)) :name :rleg)
        ))

;(send *ri* :angle-vector (send *robot* :angle-vector) 2000)
;(send *ri* :wait-interpolation)

(lower-waist 100) ;;腰を下げる

(send *ri* :set-foot-steps
  (list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
        (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector 250 0 -100  )) :name :lleg)
        (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 250 0 -100  )) :name :rleg)
	))

(send *ri* :go-pos 0.2 0 0)
)
