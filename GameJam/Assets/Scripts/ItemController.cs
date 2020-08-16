using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ItemController : MonoBehaviour
{
    public Sprite litleMuk;
    public Sprite indianaJons;
    public Sprite laraCroft;
    public Sprite montyHoll;
    public Sprite nostradama;
    private int characterCount;
  
    public int skill;
    public double coin = 100;
    // Start is called before the first frame update
    void Start()
    {
        System.Random rand = new System.Random();
        int mode = rand.Next(1, 4);
        if (mode == 1)
        {
            Globals.mainCharacter = "litleMuk";
        }
        if (mode == 2)
        {
            Globals.mainCharacter = "indianaJons";
        }
        if (mode == 3)
        {
            Globals.mainCharacter = "laraCroft";
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
