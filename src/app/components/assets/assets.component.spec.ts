import { TestBed } from "@angular/core/testing";
import { of } from "rxjs";
import { AssetsComponent } from "./assets.component";
import { AssetService } from "../../services/asset.service";

describe("AssetsComponent", () => {
  let fixture: any;

  beforeEach(async () => {
    const assetServiceStub = {
      list: () => of([]),
    } as Partial<AssetService>;

    await TestBed.configureTestingModule({
      imports: [AssetsComponent],
      providers: [{ provide: AssetService, useValue: assetServiceStub }],
    }).compileComponents();

    fixture = TestBed.createComponent(AssetsComponent);
    fixture.detectChanges();
  });

  it("should create", () => {
    const comp = fixture.componentInstance;
    expect(comp).toBeTruthy();
  });
});
