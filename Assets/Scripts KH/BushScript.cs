﻿using UnityEngine;
using System.Collections;

public class BushScript : VoxelParent
{
	public GameObject bushModel;
	public Material ruinTexture;
	Animator myAnim;

	protected override void Awake ()
	{
		bushModel.SetActive (false);
		base.Awake ();
	}

	// Use this for initialization
	protected override void Start ()
	{
		base.Start ();
		myAnim = GetComponent<Animator> ();
		//not everyone destroys the world
		if(ruinTexture != null)
		{
			vxe.changeChunkMaterial(chunkCoords, ruinTexture);
		}
	}
	
	// Update is called once per frame
	protected override void Update ()
	{
		base.Update ();
	}

	IEnumerator fall ()
	{
		Vector3 coords = Vector3.zero, norm = Vector3.zero;
		bool hit = vxe.RayCast (transform.position, Vector3.down, 64, ref coords, ref norm, 0.5f);

		Vector3 startpos = transform.position;
		coords.x = startpos.x;
		coords.z = startpos.z;
		if (hit) {
			for (float i=0; i<0.5f; i+= Time.deltaTime) {
				transform.position = Vector3.Lerp (startpos, coords, i * 2);
				Debug.Log ("falling");
				yield return null;
			}
		}
	}

	protected override void playerCloseEvent ()
	{
		base.playerCloseEvent ();
		myAnim.SetTrigger ("Stop");
	}

	protected override void playerFarEvent()
	{
		base.playerFarEvent ();
		myAnim.SetTrigger ("Play");
	}

	protected override void allTriggeredEvent ()
	{
		base.allTriggeredEvent ();
		bushModel.SetActive (true);
		StartCoroutine (fall ());
		ItemSpawner.Instance.canSpawn = true;
		vxe.changeChunkMaterial (chunkCoords, BiomeScript.Instance.getBiomeMaterialFromCoords (chunkCoords));
		myAnim.SetTrigger ("Stop");

		audioSource.PlayOneShot (AudioManager.Instance.winClip);
	}

	public override void voxelSwitchEvent ()
	{
		base.voxelSwitchEvent ();
	}
}
